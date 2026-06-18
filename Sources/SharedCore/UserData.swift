import Foundation

/// Personnalisation utilisateur appliquée par-dessus le profil.
///
/// - `whitelist` : mots que l'utilisateur protège (jamais corrigés).
/// - `rejectedCorrections` : couples "original->correction" déjà refusés,
///   filtrés des suggestions futures (blacklist de corrections).
public struct UserLists: Equatable, Sendable {
    public private(set) var whitelist: Set<String>
    public private(set) var rejectedCorrections: Set<String>

    public init(whitelist: Set<String> = [], rejectedCorrections: Set<String> = []) {
        self.whitelist = Set(whitelist.map { $0.lowercased() })
        self.rejectedCorrections = rejectedCorrections
    }

    public func isWhitelisted(_ word: String) -> Bool {
        whitelist.contains(word.lowercased())
    }

    public func isRejected(original: String, correction: String) -> Bool {
        rejectedCorrections.contains(Self.key(original, correction))
    }

    public mutating func whitelistAdd(_ word: String) {
        whitelist.insert(word.lowercased())
    }

    public mutating func reject(original: String, correction: String) {
        rejectedCorrections.insert(Self.key(original, correction))
    }

    static func key(_ a: String, _ b: String) -> String {
        "\(a.lowercased())\u{1}\(b.lowercased())"
    }
}

/// Abstraction du stockage partagé (App Group si Full Access, sinon défauts
/// embarqués). Le moteur ne dépend que de ce protocole — voir décision D4.
public protocol SettingsStore {
    func loadRegistre() -> Registre
    func loadIntensity() -> CorrectionIntensity
    func loadUserLists() -> UserLists
}

/// Implémentation de repli, 100 % embarquée : fonctionne SANS Full Access.
/// Garantit que le clavier reste utile même si l'App Group est inaccessible.
public struct EmbeddedDefaultsStore: SettingsStore {
    public init() {}
    public func loadRegistre() -> Registre { .familierQC }
    public func loadIntensity() -> CorrectionIntensity { .suggest }
    public func loadUserLists() -> UserLists { UserLists() }
}
