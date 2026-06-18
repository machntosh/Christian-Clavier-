import UIKit
import SharedCore

/// Barre de suggestions maison (iOS ne prête pas la barre native aux claviers
/// tiers). Jusqu'à 3 emplacements. Conçue pour rester stable sous frappe
/// rapide : pas d'allocation par frappe au-delà des labels réutilisés.
final class SuggestionBarView: UIView {

    var onSelect: ((Suggestion) -> Void)?
    private let stack = UIStackView()
    private var current: [Suggestion] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) non utilisé") }

    func show(_ suggestions: [Suggestion]) {
        current = Array(suggestions.prefix(3))
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, s) in current.enumerated() {
            let b = UIButton(type: .system)
            b.setTitle(s.text, for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            b.tag = i
            b.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            stack.addArrangedSubview(b)
        }
    }

    @objc private func tap(_ sender: UIButton) {
        guard current.indices.contains(sender.tag) else { return }
        onSelect?(current[sender.tag])
    }
}
