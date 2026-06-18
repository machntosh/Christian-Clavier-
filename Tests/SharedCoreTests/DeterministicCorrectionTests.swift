import XCTest
@testable import SharedCore

/// Couche 1 — corrections déterministes. Sert de corpus de non-régression :
/// critère PRD = ≥ 90 % de réussite (voir docs/test-strategy.md §2.2).
final class DeterministicCorrectionTests: XCTestCase {

    private func makeEngine(_ registre: Registre = .standard) -> CorrectionEngine {
        CorrectionEngine(lexicon: SeedData.makeLexicon(),
                         profile: SeedData.profile(for: registre))
    }

    /// Corpus "doit corriger" : entrée -> top suggestion attendu.
    func testCorpusReussiteAuMoins90Pourcent() {
        let cases: [(String, String)] = [
            ("lami", "l'ami"),
            ("jai", "j'ai"),
            ("cest", "c'est"),
            ("dun", "d'un"),
            ("quil", "qu'il"),
            ("ecole", "école"),
            ("etre", "être"),
            ("eleve", "élève"),
            ("aujourdhui", "aujourd'hui"),
            ("bientot", "bientôt"),
            ("peutetre", "peut-être"),
            ("tres", "très"),
            ("meme", "même"),
            ("apres", "après")
        ]
        let engine = makeEngine()
        var ok = 0
        var failures: [String] = []
        for (input, expected) in cases {
            let result = engine.process(WordContext(word: input))
            if result.suggestions.first?.text == expected {
                ok += 1
            } else {
                failures.append("\(input) -> \(result.suggestions.first?.text ?? "∅") (attendu \(expected))")
            }
        }
        let rate = Double(ok) / Double(cases.count)
        XCTAssertGreaterThanOrEqual(rate, 0.9,
            "Taux \(Int(rate*100))% < 90%. Échecs: \(failures)")
    }

    func testApostropheElision() {
        let e = makeEngine()
        XCTAssertEqual(e.process(WordContext(word: "lami")).suggestions.first?.text, "l'ami")
        XCTAssertEqual(e.process(WordContext(word: "quil")).suggestions.first?.text, "qu'il")
    }

    func testApostropheRespecteLaCasse() {
        let e = makeEngine()
        XCTAssertEqual(e.process(WordContext(word: "Lami")).suggestions.first?.text, "L'ami")
    }

    func testMotValideNEstPasCorrige() {
        let e = makeEngine()
        // "des", "ces", "dans" sont au lexique : aucune élision parasite.
        XCTAssertTrue(e.process(WordContext(word: "des")).suggestions.isEmpty)
        XCTAssertTrue(e.process(WordContext(word: "dans")).suggestions.isEmpty)
    }

    func testAccentParRepliLexical() {
        let e = makeEngine()
        XCTAssertEqual(e.process(WordContext(word: "ecole")).suggestions.first?.text, "école")
    }

    func testFauteUsuelleParTable() {
        let e = makeEngine()
        XCTAssertEqual(e.process(WordContext(word: "aujourdhui")).suggestions.first?.text,
                       "aujourd'hui")
    }
}
