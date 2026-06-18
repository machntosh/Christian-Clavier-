import XCTest
@testable import SharedCore

/// Couches 2 (distance d'édition) et 3 (homophones), + algorithme DL.
final class AdvancedLayersTests: XCTestCase {

    private func engine() -> CorrectionEngine {
        CorrectionEngine(lexicon: SeedData.makeLexicon(),
                         profile: SeedData.profile(for: .standard))
    }

    func testDistanceEditionProposeLeMotProche() {
        // "bote" -> "botte" (insertion, distance 1).
        XCTAssertEqual(engine().process(WordContext(word: "bote")).suggestions.first?.text,
                       "botte")
    }

    func testDamerauLevenshteinTransposition() {
        // transposition = distance 1
        XCTAssertEqual(EditDistanceLayer.damerauLevenshtein(Array("acb"), Array("abc"), max: 2), 1)
        XCTAssertEqual(EditDistanceLayer.damerauLevenshtein(Array("chat"), Array("chat"), max: 2), 0)
        XCTAssertEqual(EditDistanceLayer.damerauLevenshtein(Array("chat"), Array("chien"), max: 2), 3)
    }

    func testHomophoneAvecContexteGauche() {
        // "il et content" -> "il est"
        let r = engine().process(WordContext(word: "et", leftWords: ["il"]))
        XCTAssertEqual(r.suggestions.first?.text, "est")
    }

    func testHomophoneSansContexteNeProposeRien() {
        // Contexte gauche vide (cas réel du proxy) : dégradation gracieuse.
        let r = engine().process(WordContext(word: "et", leftWords: []))
        XCTAssertTrue(r.suggestions.allSatisfy { $0.kind != .homophone })
    }
}
