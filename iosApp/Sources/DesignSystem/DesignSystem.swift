import SwiftUI
import UIKit

enum SwingTheme {
    // Paleta oficial do portal Swing Brasília.
    enum Palette {
        static let background = Color(red: 0.988, green: 0.973, blue: 0.957)   // #FCF8F4
        static let surface = Color.white                                          // #FFFFFF
        static let surfaceMuted = Color(red: 0.949, green: 0.918, blue: 0.894)    // #F2EAE4
        static let textPrimary = Color(red: 0.153, green: 0.094, blue: 0.153)     // #271827
        static let textSecondary = Color(red: 0.435, green: 0.384, blue: 0.420)   // #6F626B
        static let brand = Color(red: 0.494, green: 0.188, blue: 0.282)           // #7E3048
        static let brandAction = Color(red: 0.698, green: 0.278, blue: 0.396)     // #B24765
        static let brandSoft = Color(red: 0.957, green: 0.867, blue: 0.890)       // #F4DDE3
        static let champagne = Color(red: 0.761, green: 0.608, blue: 0.384)       // #C29B62
        static let border = Color(red: 0.894, green: 0.847, blue: 0.820)          // #E4D8D1
        static let overlay = Color(red: 0.094, green: 0.039, blue: 0.075, opacity: 0.62) // rgba(24,10,19,.62)
    }
}

// MARK: - Carregador de imagens (folder reference em Resources/Images)

enum SwingImage {
    static func uiImage(_ filename: String) -> UIImage? {
        let name = (filename as NSString).deletingPathExtension
        let ext = (filename as NSString).pathExtension
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }

    static func view(_ filename: String) -> Image {
        if let image = uiImage(filename) {
            return Image(uiImage: image)
        }
        return Image(systemName: "photo")
    }
}

// MARK: - Marca

struct BrandMark: View {
    var size: CGFloat = 28

    var body: some View {
        ZStack {
            Circle()
                .fill(SwingTheme.Palette.brand)
            Text("S")
                .font(.system(size: size * 0.56, weight: .bold, design: .serif))
                .foregroundStyle(SwingTheme.Palette.background)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct Brand: View {
    var body: some View {
        HStack(spacing: 8) {
            BrandMark(size: 26)
            title
        }
        .accessibilityLabel("Swing Brasília")
    }

    private var title: some View {
        (Text("SWING ").font(.caption.weight(.semibold)) + Text("BRASÍLIA").font(.caption.weight(.heavy)))
            .tracking(1.2)
            .foregroundStyle(SwingTheme.Palette.textPrimary)
    }
}

// MARK: - Rótulo de seção

struct Eyebrow: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.caption2.weight(.bold))
            .tracking(1.6)
            .foregroundStyle(SwingTheme.Palette.champagne)
    }
}

// MARK: - Estilos de botão

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(SwingTheme.Palette.brandAction.opacity(configuration.isPressed ? 0.8 : 1))
            .clipShape(Capsule())
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(SwingTheme.Palette.brand)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(SwingTheme.Palette.brand.opacity(configuration.isPressed ? 0.1 : 0))
            .overlay(Capsule().stroke(SwingTheme.Palette.brand, lineWidth: 1.2))
            .clipShape(Capsule())
    }
}

// MARK: - Cartão base

struct SwingCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(SwingTheme.Palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(SwingTheme.Palette.border, lineWidth: 1)
            )
    }
}

extension View {
    func swingCard() -> some View { modifier(SwingCard()) }
}
