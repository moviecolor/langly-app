import Foundation

/// Decides whether a user has full block access to Langly, and how many
/// word blocks the free tier keeps. Pure logic so it can be unit-tested.
///
/// Rules:
/// - Full access = active Premium subscription OR the 7-day trial is running.
/// - Free tier keeps only the two OLDEST blocks after the trial ends.
/// - Legacy installs (no `installDate` stamp) get full access so nobody is
///   locked out by a missing clock.
enum PremiumAccess {
    /// Free word blocks kept after the trial ends.
    static let freeBlockLimit = 2

    /// 7 days of full access from first launch.
    static let trialDuration: TimeInterval = 7 * 24 * 60 * 60

    /// True during the trial, or when the trial clock was never stamped.
    static func isTrialActive(installDate: Date?, now: Date = .now) -> Bool {
        guard let installDate else { return true }
        return now.timeIntervalSince(installDate) < trialDuration
    }

    /// True when block creation and all blocks are available.
    static func hasFullAccess(isPremium: Bool, installDate: Date?, now: Date = .now) -> Bool {
        isPremium || isTrialActive(installDate: installDate, now: now)
    }

    /// The blocks the free tier keeps: two oldest by creation date (nil
    /// creation dates sort oldest — legacy blocks stay free).
    static func freeBlocks(from blocks: [WordBlock]) -> [WordBlock] {
        let ordered = blocks.sorted {
            ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast)
        }
        return Array(ordered.prefix(freeBlockLimit))
    }

    /// Whether a specific block is locked (after trial, non-premium, and it is
    /// not one of the two oldest kept blocks).
    static func isBlockLocked(
        _ block: WordBlock,
        isPremium: Bool,
        installDate: Date?,
        allBlocks: [WordBlock],
        now: Date = .now
    ) -> Bool {
        guard !hasFullAccess(isPremium: isPremium, installDate: installDate, now: now) else {
            return false
        }
        return !freeBlocks(from: allBlocks).contains { $0.id == block.id }
    }

    /// Whether the user may still create a new block.
    static func canAddBlocks(
        isPremium: Bool,
        installDate: Date?,
        currentBlockCount: Int,
        maxBlocks: Int,
        now: Date = .now
    ) -> Bool {
        hasFullAccess(isPremium: isPremium, installDate: installDate, now: now)
            && currentBlockCount < maxBlocks
    }
}