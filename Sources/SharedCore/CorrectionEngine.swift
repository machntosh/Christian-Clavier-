import Foundation

/// Réglages d'exécution du moteur.
public struct EngineConfig: Sendable {
    public var maxSuggestions: Int
    /// Couches désactivées (réglage utilisateur OU dégradation forcée).
    /// Sert aussi à POC-FALLBACK : on coupe les couches avancées et on vérifie
    /// que les corrections de base subsistent.
    public var disabledLayerIDs: Set<String>
    public var minConfidenceSuggest: Double
    public var minConfidenceAggressive: Double

    public init(maxSuggestions: Int = 3,
                disabledLayerIDs: Set<String> = [],
                minConfidenceSuggest: Double = 0.6,
                minConfidenceAggressive: Double = 0.4) {
        self.maxSuggestions = maxSuggestions
        self.disabledLayerIDs = disabledLayerIDs
        self.minConfidenceSuggest = minConfidenceSuggest
        self.minConfidenceAggressive = minConfidenceAggressive
    }
}

/// Orchestrateur des couches de correction.
///
/// Garanties (D3 — dégradation gracieuse) :
///  - ne lève jamais d'exception : `process` retourne toujours un résultat,
///  - une couche désactivée ou stérile est simplement ignorée,
///  - whitelist utilisateur et lexique de profil court-circuitent toute
///    correction (préservation du registre familier).
public final class CorrectionEngine {

    private let layers: [CorrectionLayer]
    private let lexicon: Lexicon
    public var profile: Profile
    public var userLists: UserLists
    public var config: EngineConfig

    /// Pile de couches par défaut, ordre du plus sûr au plus spéculatif.
    public static func defaultLayers() -> [CorrectionLayer] {
        [
            ApostropheLayer(),
            AccentLayer(),
            CommonMistakeLayer(),
            ContractionLayer(),
            HomophoneLayer(),
            EditDistanceLayer()
        ]
    }

    public init(lexicon: Lexicon,
                profile: Profile,
                userLists: UserLists = UserLists(),
                config: EngineConfig = EngineConfig(),
                layers: [CorrectionLayer]? = nil) {
        self.lexicon = lexicon
        self.profile = profile
        self.userLists = userLists
        self.config = config
        self.layers = layers ?? Self.defaultLayers()
    }

    /// Point d'entrée appelé par l'extension pour le mot courant.
    public func process(_ ctx: WordContext) -> CorrectionResult {
        // 0. Intensité OFF : rien à proposer.
        guard profile.intensity != .off else { return .none(ctx.word) }

        // 1. Whitelist utilisateur : protection absolue.
        if userLists.isWhitelisted(ctx.word) {
            return CorrectionResult(original: ctx.word, suggestions: [],
                                    protectedByUser: true, protectedByProfile: false)
        }
        // 2. Lexique du registre actif : on préserve le familier.
        if profile.isProtected(ctx.word) {
            return CorrectionResult(original: ctx.word, suggestions: [],
                                    protectedByUser: false, protectedByProfile: true)
        }

        let deps = LayerContext(profile: profile, lexicon: lexicon, userLists: userLists)
        var collected: [Suggestion] = []

        // 3. Exécution des couches actives. Chaque couche est isolée : un retour
        //    vide n'empêche pas les suivantes.
        for layer in layers where !config.disabledLayerIDs.contains(layer.id) {
            let out = layer.suggest(ctx, deps)
            for s in out where !s.text.isEmpty && s.text.lowercased() != ctx.word.lowercased() {
                // 4. Blacklist : on retire les corrections déjà refusées.
                if userLists.isRejected(original: ctx.word, correction: s.text) { continue }
                collected.append(s)
            }
        }

        // 5. Seuil de confiance selon l'intensité.
        let threshold = profile.intensity == .aggressive
            ? config.minConfidenceAggressive
            : config.minConfidenceSuggest
        collected = collected.filter { $0.confidence >= threshold }

        // 6. Dédoublonnage par texte (garde la meilleure confiance).
        var best: [String: Suggestion] = [:]
        for s in collected {
            let key = s.text.lowercased()
            if let prev = best[key], prev.confidence >= s.confidence { continue }
            best[key] = s
        }

        // 7. Tri : confiance décroissante, puis priorité de nature.
        let ordered = best.values.sorted {
            if $0.confidence != $1.confidence { return $0.confidence > $1.confidence }
            return kindPriority($0.kind) < kindPriority($1.kind)
        }

        return CorrectionResult(original: ctx.word,
                                suggestions: Array(ordered.prefix(config.maxSuggestions)),
                                protectedByUser: false, protectedByProfile: false)
    }

    private func kindPriority(_ k: SuggestionKind) -> Int {
        switch k {
        case .apostrophe: return 0
        case .accent:     return 1
        case .spelling:   return 2
        case .homophone:  return 3
        case .contraction:return 4
        case .usage:      return 5
        }
    }
}
