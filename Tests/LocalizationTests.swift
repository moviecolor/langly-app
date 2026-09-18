import XCTest
@testable import Langly

final class LocalizationTests: XCTestCase {
    /// Every key in the chrome table must have a non-empty EN and PT value.
    func testEveryKeyHasBothLanguages() {
        for (key, pair) in Localization.table {
            XCTAssertFalse(key.isEmpty, "Table contains an empty key")
            XCTAssertFalse(pair.en.isEmpty, "Key '\(key)' has an empty English string")
            XCTAssertFalse(pair.pt.isEmpty, "Key '\(key)' has an empty Portuguese string")
        }
    }

    /// The chrome surface needs a substantial key set; fewer than 40 pairs
    /// would mean a screen is still hardcoded English.
    func testKeyCountIsAtLeastForty() {
        XCTAssertGreaterThanOrEqual(Localization.table.count, 40)
    }

    /// English home (and nil/unknown) renders the English column.
    func testEnglishHomeReturnsEnglish() {
        XCTAssertEqual(Localization.string("module.vocabulary", homeLanguage: "English"), "Vocabulary")
        XCTAssertEqual(Localization.string("settings.title", homeLanguage: nil), "Settings")
        XCTAssertEqual(Localization.string("paywall.restore", homeLanguage: "Unknown"), "Restore Purchase")
    }

    /// Portuguese home renders the Brazilian Portuguese column.
    func testPortugueseHomeReturnsPortuguese() {
        XCTAssertEqual(Localization.string("module.vocabulary", homeLanguage: "Portuguese"), "Vocabulário")
        XCTAssertEqual(Localization.string("settings.title", homeLanguage: "Portuguese"), "Configurações")
        XCTAssertEqual(Localization.string("paywall.restore", homeLanguage: "Portuguese"), "Restaurar Compra")
        XCTAssertEqual(Localization.string("onboarding.continue", homeLanguage: "Portuguese"), "Continuar")
    }

    /// Format keys keep their placeholders in both languages.
    func testFormatKeysPreservePlaceholders() {
        XCTAssertTrue(Localization.table["onboarding.getStarted.body"]!.en.contains("%@"))
        XCTAssertTrue(Localization.table["onboarding.getStarted.body"]!.pt.contains("%@"))
        XCTAssertTrue(Localization.table["stats.daysValue"]!.en.contains("%d"))
        XCTAssertTrue(Localization.table["stats.daysValue"]!.pt.contains("%d"))
        XCTAssertTrue(Localization.table["paywall.subscribe"]!.pt.contains("%@"))
    }
}