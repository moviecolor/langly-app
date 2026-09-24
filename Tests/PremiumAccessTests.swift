import XCTest
@testable import Langly

/// Unit tests for the PremiumAccess gate: 7-day trial, 2-block free limit,
/// legacy installs, and premium bypass.
final class PremiumAccessTests: XCTestCase {
    private func makeBlock(name: String, createdAt: Date? = .now) -> WordBlock {
        WordBlock(blockName: name, vocabularyWords: [], isActive: true, createdAt: createdAt)
    }

    // MARK: - Trial

    func testTrialActiveDuringFirstSevenDays() {
        let install = Date(timeIntervalSinceNow: -3 * 24 * 60 * 60) // 3 days ago
        XCTAssertTrue(PremiumAccess.isTrialActive(installDate: install, now: .now))
    }

    func testTrialExpiredAfterSevenDays() {
        let install = Date(timeIntervalSinceNow: -8 * 24 * 60 * 60) // 8 days ago
        XCTAssertFalse(PremiumAccess.isTrialActive(installDate: install, now: .now))
    }

    func testTrialBoundaryExactlyAtSevenDays() {
        // At exactly 7 days the trial has elapsed (>= 7 days = over).
        let install = Date(timeIntervalSinceNow: -7 * 24 * 60 * 60)
        XCTAssertFalse(PremiumAccess.isTrialActive(installDate: install, now: .now))
    }

    func testMissingInstallDateTreatsAsFullAccess() {
        XCTAssertTrue(PremiumAccess.isTrialActive(installDate: nil, now: .now))
    }

    // MARK: - Full access

    func testPremiumIsFullAccessEvenAfterTrial() {
        let install = Date(timeIntervalSinceNow: -30 * 24 * 60 * 60)
        XCTAssertTrue(PremiumAccess.hasFullAccess(isPremium: true, installDate: install, now: .now))
    }

    func testTrialYieldsFullAccess() {
        let install = Date(timeIntervalSinceNow: -2 * 24 * 60 * 60)
        XCTAssertTrue(PremiumAccess.hasFullAccess(isPremium: false, installDate: install, now: .now))
    }

    func testExpiredTrialWithoutPremiumIsNotFullAccess() {
        let install = Date(timeIntervalSinceNow: -10 * 24 * 60 * 60)
        XCTAssertFalse(PremiumAccess.hasFullAccess(isPremium: false, installDate: install, now: .now))
    }

    // MARK: - Free blocks selection

    func testFreeBlocksKeepsTwoOldest() {
        let old = makeBlock(name: "Oldest", createdAt: Date(timeIntervalSinceNow: -50 * 86_400))
        let mid = makeBlock(name: "Middle", createdAt: Date(timeIntervalSinceNow: -20 * 86_400))
        let new = makeBlock(name: "Newest", createdAt: Date(timeIntervalSinceNow: -1 * 86_400))

        let free = PremiumAccess.freeBlocks(from: [new, old, mid])
        XCTAssertEqual(free.map(\.blockName), ["Oldest", "Middle"])
    }

    func testFreeBlocksWithLegacyNilCreatedAtKeepsLegacyFirst() {
        let legacy = makeBlock(name: "Legacy", createdAt: nil)
        let new = makeBlock(name: "New", createdAt: .now)

        let free = PremiumAccess.freeBlocks(from: [new, legacy])
        XCTAssertEqual(free.map(\.blockName), ["Legacy", "New"])
    }

    func testFreeBlocksWhenOnlyThreeExists() {
        let a = makeBlock(name: "A", createdAt: Date(timeIntervalSinceNow: -9 * 86_400))
        let b = makeBlock(name: "B", createdAt: Date(timeIntervalSinceNow: -8 * 86_400))
        let c = makeBlock(name: "C", createdAt: Date(timeIntervalSinceNow: -7 * 86_400))

        let free = PremiumAccess.freeBlocks(from: [c, a, b])
        XCTAssertEqual(free.map(\.blockName), ["A", "B"])
        XCTAssertEqual(free.count, PremiumAccess.freeBlockLimit)
    }

    // MARK: - Block locking

    func testOldestTwoBlocksStayUnlockedAfterTrial() {
        let install = Date(timeIntervalSinceNow: -14 * 86_400)
        let a = makeBlock(name: "A", createdAt: Date(timeIntervalSinceNow: -14 * 86_400))
        let b = makeBlock(name: "B", createdAt: Date(timeIntervalSinceNow: -13 * 86_400))
        let c = makeBlock(name: "C", createdAt: Date(timeIntervalSinceNow: -12 * 86_400))

        XCTAssertFalse(PremiumAccess.isBlockLocked(a, isPremium: false, installDate: install, allBlocks: [a, b, c], now: .now))
        XCTAssertFalse(PremiumAccess.isBlockLocked(b, isPremium: false, installDate: install, allBlocks: [a, b, c], now: .now))
        XCTAssertTrue(PremiumAccess.isBlockLocked(c, isPremium: false, installDate: install, allBlocks: [a, b, c], now: .now))
    }

    func testNoBlocksLockedDuringTrial() {
        let install = Date(timeIntervalSinceNow: -2 * 86_400)
        let a = makeBlock(name: "A", createdAt: .now)
        let b = makeBlock(name: "B", createdAt: .now)
        XCTAssertFalse(PremiumAccess.isBlockLocked(a, isPremium: false, installDate: install, allBlocks: [a, b], now: .now))
        XCTAssertFalse(PremiumAccess.isBlockLocked(b, isPremium: false, installDate: install, allBlocks: [a, b], now: .now))
    }

    func testNoBlocksLockedForPremium() {
        let install = Date(timeIntervalSinceNow: -30 * 86_400)
        let third = makeBlock(name: "Third", createdAt: .now)
        XCTAssertFalse(PremiumAccess.isBlockLocked(third, isPremium: true, installDate: install, allBlocks: [third], now: .now))
    }

    // MARK: - Add block capability

    func testCannotAddAfterTrialAtLimit() {
        let install = Date(timeIntervalSinceNow: -10 * 86_400)
        XCTAssertFalse(
            PremiumAccess.canAddBlocks(
                isPremium: false,
                installDate: install,
                currentBlockCount: PremiumAccess.freeBlockLimit,
                maxBlocks: 10,
                now: .now
            )
        )
    }

    func testCanAddDuringTrial() {
        let install = Date(timeIntervalSinceNow: -1 * 86_400)
        XCTAssertTrue(
            PremiumAccess.canAddBlocks(
                isPremium: false,
                installDate: install,
                currentBlockCount: PremiumAccess.freeBlockLimit,
                maxBlocks: 10,
                now: .now
            )
        )
    }

    func testCannotAddAtHardCap() {
        let install = Date(timeIntervalSinceNow: -1 * 86_400)
        XCTAssertFalse(
            PremiumAccess.canAddBlocks(
                isPremium: true,
                installDate: install,
                currentBlockCount: 10,
                maxBlocks: 10,
                now: .now
            )
        )
    }

    func testPremiumCanAddBeyondFreeLimit() {
        let install = Date(timeIntervalSinceNow: -20 * 86_400)
        XCTAssertTrue(
            PremiumAccess.canAddBlocks(
                isPremium: true,
                installDate: install,
                currentBlockCount: 5,
                maxBlocks: 10,
                now: .now
            )
        )
    }
}