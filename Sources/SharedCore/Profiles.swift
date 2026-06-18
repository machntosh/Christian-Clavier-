import Foundation

/// Intensité de correction choisie par l'utilisateur.
public enum CorrectionIntensity: String, Equatable, Sendable, CaseIterable {
    case off        // aucune suggestion
    case suggest    // propose, n'impose rien (défaut)
    case aggressive // propose aussi les candidats à plus faible confiance
}

/// Registre / profil linguistique actif.
public enum Registre: String, Equatable, Sendable, CaseIterable {
    case familierQC = "familier_qc"
    case familierFR = "familier_fr"
    case standard   = "standard"
}

/// Profil = lexique protégé (jamais corrigé) + contractions connues + réglages.
public struct Profile: Equatable, Sendable {
    public let registre: Registre
    /// Mots du registre à ne JAMAIS corriger (chu, tsé, wesh…).
    public let protectedLexicon: Set<String>
    /// Contractions connues : forme familière -> forme standard.
    /// Utilisées pour proposer une expansion uniquement en registre `standard`.
    public let contractions: [String: String]
    public var intensity: CorrectionIntensity

    public init(registre: Registre,
                protectedLexicon: Set<String>,
                contractions: [String: String] = [:],
                intensity: CorrectionIntensity = .suggest) {
        self.registre = registre
        self.protectedLexicon = Set(protectedLexicon.map { $0.lowercased() })
        self.contractions = contractions
        self.intensity = intensity
    }

    public func isProtected(_ word: String) -> Bool {
        protectedLexicon.contains(word.lowercased())
    }
}
