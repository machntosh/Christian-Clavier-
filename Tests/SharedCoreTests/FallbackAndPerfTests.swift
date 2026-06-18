import XCTest
@testable import SharedCore

/// POC-FALLBACK (testable) + smoke test de latence (POC-LAT, indicatif).
final class FallbackAndPerfTests: XCTestCase {

    private func makeEngine(disabled: Set<String> = []) -> CorrectionEngine {
        CorrectionEngine(lexicon: SeedData.makeLexicon(),
                         profile: SeedData.profile(for: .standard),
                         config: EngineConfig(disabledLayerIDs: disabled))
    }

    func testFallbackCouchesAvanceesCoupees() {
        // On coupe distance d'édition, homophones et contractions.
        // Les corrections de base (apostrophe/accent/faute usuelle) subsistent.
        let e = makeEngine(disabled: ["edit_distance", "homophone", "contraction"])
        XCTAssertEqual(e.process(WordContext(word: "lami")).suggestions.first?.text, "l'ami")
        XCTAssertEqual(e.process(WordContext(word: "ecole")).suggestions.first?.text, "école")
    }

    func testToutesCouchesCoupeesNeCrashePas() {
        let all: Set<String> = ["apostrophe", "accent", "common_mistake",
                                "contraction", "homophone", "edit_distance"]
        let e = makeEngine(disabled: all)
        // Aucune suggestion mais aucune erreur : le clavier resterait utilisable.
        XCTAssertTrue(e.process(WordContext(word: "lami")).suggestions.isEmpty)
    }

    /// Smoke test indicatif. La VRAIE latence se mesure sur device (POC-LAT) ;
    /// ici on vérifie juste l'absence de régression grossière de complexité.
    func testLatenceSmoke() {
        let e = makeEngine()
        let mots = ["lami", "ecole", "bote", "aujourdhui", "chu", "etre",
                    "quil", "des", "bonjour", "xyzabc"]
        let start = Date()
        let iterations = 500
        for _ in 0..<iterations {
            for m in mots { _ = e.process(WordContext(word: m)) }
        }
        let elapsed = Date().timeIntervalSince(start)
        let perWordMs = (elapsed / Double(iterations * mots.count)) * 1000
        // Borne large (machine de dev, pas device). Sert d'alarme anti-explosion.
        XCTAssertLessThan(perWordMs, 5.0, "Latence moyenne \(perWordMs) ms/mot trop élevée")
    }
}
