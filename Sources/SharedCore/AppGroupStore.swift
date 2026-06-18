import Foundation

/// Identifiants partagés app ↔ extension.
public enum AppGroup {
    /// À aligner avec l'entitlement App Group des deux cibles Xcode.
    public static let suiteName = "group.com.clavierfr.shared"

    enum Key {
        static let registre = "settings.registre"
        static let intensity = "settings.intensity"
        static let whitelist = "settings.whitelist"
        static let rejected = "settings.rejected"
    }
}

/// Stockage partagé via App Group (UserDefaults suite).
///
/// Décision D4 : c'est un ENRICHISSEMENT, pas une dépendance dure. Si la suite
/// est indisponible (Full Access OFF → `UserDefaults(suiteName:)` peut renvoyer
/// nil ou un store inaccessible), on retombe sur les valeurs embarquées. Le
/// clavier reste pleinement utile. Couvre POC-IPC.
public struct AppGroupStore: SettingsStore {
    private let defaults: UserDefaults?
    private let fallback = EmbeddedDefaultsStore()

    public init(suiteName: String = AppGroup.suiteName) {
        self.defaults = UserDefaults(suiteName: suiteName)
    }

    /// Indique si le conteneur partagé est réellement accessible
    /// (proxy de "Full Access activé" pour l'UI d'onboarding).
    public var isShortedToFallback: Bool { defaults == nil }

    public func loadRegistre() -> Registre {
        guard let raw = defaults?.string(forKey: AppGroup.Key.registre),
              let r = Registre(rawValue: raw) else { return fallback.loadRegistre() }
        return r
    }

    public func loadIntensity() -> CorrectionIntensity {
        guard let raw = defaults?.string(forKey: AppGroup.Key.intensity),
              let i = CorrectionIntensity(rawValue: raw) else { return fallback.loadIntensity() }
        return i
    }

    public func loadUserLists() -> UserLists {
        guard let d = defaults else { return fallback.loadUserLists() }
        let white = Set(d.stringArray(forKey: AppGroup.Key.whitelist) ?? [])
        let rejected = Set(d.stringArray(forKey: AppGroup.Key.rejected) ?? [])
        return UserLists(whitelist: white, rejectedCorrections: rejected)
    }

    // MARK: - Écriture (utilisée par l'app principale)

    public func save(registre: Registre) {
        defaults?.set(registre.rawValue, forKey: AppGroup.Key.registre)
    }

    public func save(intensity: CorrectionIntensity) {
        defaults?.set(intensity.rawValue, forKey: AppGroup.Key.intensity)
    }

    public func saveWhitelist(_ words: [String]) {
        defaults?.set(words.map { $0.lowercased() }, forKey: AppGroup.Key.whitelist)
    }
}
