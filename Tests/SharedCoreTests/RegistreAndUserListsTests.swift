import XCTest
@testable import SharedCore

/// Préservation du registre familier + personnalisation utilisateur.
/// Critère PRD : 0 faux positif sur le lexique du registre actif.
final class RegistreAndUserListsTests: XCTestCase {

    func testRegistreQCProtegeLeFamilier() {
        let e = CorrectionEngine(lexicon: SeedData.makeLexicon(),
                                 profile: SeedData.profile(for: .familierQC))
        let r = e.process(WordContext(word: "chu"))
        XCTAssertTrue(r.protectedByProfile)
        XCTAssertTrue(r.suggestions.isEmpty, "Le registre QC ne doit pas corriger 'chu'")
    }

    func testRegistreFRProtegeLeFamilier() {
        let e = CorrectionEngine(lexicon: SeedData.makeLexicon(),
                                 profile: SeedData.profile(for: .familierFR))
        XCTAssertTrue(e.process(WordContext(word: "wesh")).protectedByProfile)
        XCTAssertTrue(e.process(WordContext(word: "ouais")).suggestions.isEmpty)
    }

    func testRegistreStandardProposeExpansion() {
        let e = CorrectionEngine(lexicon: SeedData.makeLexicon(),
                                 profile: SeedData.profile(for: .standard))
        XCTAssertEqual(e.process(WordContext(word: "chu")).suggestions.first?.text, "je suis")
    }

    func testWhitelistProtegeAbsolument() {
        var lists = UserLists()
        lists.whitelistAdd("lami")
        let e = CorrectionEngine(lexicon: SeedData.makeLexicon(),
                                 profile: SeedData.profile(for: .standard),
                                 userLists: lists)
        let r = e.process(WordContext(word: "lami"))
        XCTAssertTrue(r.protectedByUser)
        XCTAssertTrue(r.suggestions.isEmpty)
    }

    func testBlacklistFiltreUneCorrectionRefusee() {
        var lists = UserLists()
        lists.reject(original: "lami", correction: "l'ami")
        let e = CorrectionEngine(lexicon: SeedData.makeLexicon(),
                                 profile: SeedData.profile(for: .standard),
                                 userLists: lists)
        let texts = e.process(WordContext(word: "lami")).suggestions.map(\.text)
        XCTAssertFalse(texts.contains("l'ami"))
    }

    func testIntensiteOffNeProposeRien() {
        let e = CorrectionEngine(lexicon: SeedData.makeLexicon(),
                                 profile: SeedData.profile(for: .standard, intensity: .off))
        XCTAssertTrue(e.process(WordContext(word: "lami")).suggestions.isEmpty)
    }
}
