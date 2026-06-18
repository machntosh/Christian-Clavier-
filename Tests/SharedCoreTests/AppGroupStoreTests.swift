import XCTest
@testable import SharedCore

/// POC-IPC (partie logique) : aller-retour d'écriture/lecture + dégradation.
final class AppGroupStoreTests: XCTestCase {

    func testAllerRetourReglages() throws {
        // Suite de test isolée (pas l'App Group réel, indispo hors device).
        let suite = "test.suite.\(UUID().uuidString)"
        let store = AppGroupStore(suiteName: suite)
        defer { UserDefaults().removePersistentDomain(forName: suite) }

        store.save(registre: .familierFR)
        store.save(intensity: .aggressive)
        store.saveWhitelist(["wesh", "kiffer"])

        XCTAssertEqual(store.loadRegistre(), .familierFR)
        XCTAssertEqual(store.loadIntensity(), .aggressive)
        XCTAssertTrue(store.loadUserLists().isWhitelisted("wesh"))
    }

    func testDefautsEmbarquesQuandRien() {
        let store = EmbeddedDefaultsStore()
        // Sans Full Access / sans données : valeurs par défaut sûres.
        XCTAssertEqual(store.loadRegistre(), .familierQC)
        XCTAssertEqual(store.loadIntensity(), .suggest)
        XCTAssertTrue(store.loadUserLists().whitelist.isEmpty)
    }
}
