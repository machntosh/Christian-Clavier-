import UIKit

enum KeyEvent {
    case char(String)
    case space
    case backspace
    case returnKey
}

/// Disposition AZERTY minimale (MVP). Le plan 0 (frappe brute) doit rester
/// trivial et robuste ; l'esthétique et les variantes (majuscules, chiffres)
/// relèvent du polish (ISSUE-503).
final class SimpleKeyboardView: UIView {

    var onKey: ((KeyEvent) -> Void)?

    private let rows = [
        "azertyuiop",
        "qsdfghjklm",
        "wxcvbn"
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildRows()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) non utilisé") }

    private func buildRows() {
        let vertical = UIStackView()
        vertical.axis = .vertical
        vertical.distribution = .fillEqually
        vertical.spacing = 6
        vertical.translatesAutoresizingMaskIntoConstraints = false
        addSubview(vertical)
        NSLayoutConstraint.activate([
            vertical.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            vertical.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            vertical.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            vertical.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4)
        ])

        for row in rows {
            let h = UIStackView()
            h.axis = .horizontal
            h.distribution = .fillEqually
            h.spacing = 4
            for ch in row {
                h.addArrangedSubview(makeButton(String(ch)) { [weak self] in
                    self?.onKey?(.char(String(ch)))
                })
            }
            vertical.addArrangedSubview(h)
        }

        // Rangée fonctionnelle : espace, retour, effacement.
        let bottom = UIStackView()
        bottom.axis = .horizontal
        bottom.distribution = .fillEqually
        bottom.spacing = 4
        bottom.addArrangedSubview(makeButton("⌫") { [weak self] in self?.onKey?(.backspace) })
        bottom.addArrangedSubview(makeButton("espace") { [weak self] in self?.onKey?(.space) })
        bottom.addArrangedSubview(makeButton("⏎") { [weak self] in self?.onKey?(.returnKey) })
        vertical.addArrangedSubview(bottom)
    }

    private func makeButton(_ title: String, action: @escaping () -> Void) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18)
        b.backgroundColor = UIColor.secondarySystemBackground
        b.layer.cornerRadius = 5
        b.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return b
    }
}
