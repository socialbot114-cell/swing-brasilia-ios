import SwiftUI

struct AgeGateView: View {
    @EnvironmentObject private var ageGate: AgeGateStore
    @Environment(\.openURL) private var openURL

    var body: some View {
        ZStack {
            SwingTheme.Palette.brand.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(SwingTheme.Palette.background.opacity(0.12))
                            .frame(width: 120, height: 120)
                        HStack(spacing: 2) {
                            Text("18")
                                .font(.system(size: 44, weight: .black, design: .serif))
                                .foregroundStyle(SwingTheme.Palette.background)
                            Text("+")
                                .font(.system(size: 24, weight: .black, design: .serif))
                                .foregroundStyle(SwingTheme.Palette.champagne)
                        }
                    }
                    Eyebrow(text: "ENTRADA CONTROLADA · SWINGBRASILIA.FUN")
                        .foregroundStyle(SwingTheme.Palette.champagne)
                    Text("A noite começa com responsabilidade.")
                        .font(.title2.weight(.bold).leading(.tight))
                        .foregroundStyle(SwingTheme.Palette.background)
                        .multilineTextAlignment(.center)
                    Text("Este guia é exclusivo para maiores de 18 anos. Ao continuar, você confirma sua idade e aceita navegar com respeito pelos limites de todas as pessoas.")
                        .font(.subheadline)
                        .foregroundStyle(SwingTheme.Palette.background.opacity(0.85))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 28)
                Spacer()
                VStack(spacing: 12) {
                    Button {
                        ageGate.confirm()
                    } label: {
                        Label("Tenho 18 anos ou mais", systemImage: "checkmark.seal.fill")
                    }
                    .buttonStyle(AgeConfirmStyle())
                    Button {
                        openURL(AppConfig.exitURL)
                    } label: {
                        Text("Sair do app")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(SwingTheme.Palette.background.opacity(0.8))
                    }
                    Text("Sem conteúdo explícito. Sem exposição. Sem pressão.")
                        .font(.caption2)
                        .foregroundStyle(SwingTheme.Palette.background.opacity(0.6))
                        .padding(.top, 8)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 32)
            }
        }
    }
}

private struct AgeConfirmStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(SwingTheme.Palette.brand)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(SwingTheme.Palette.background.opacity(configuration.isPressed ? 0.85 : 1))
            .clipShape(Capsule())
    }
}
