import SwiftUI

struct RulesView: View {
    @Environment(\.openURL) private var openURL

    @State private var confirmedAge = false
    @State private var acceptedRules = false

    private let rules = [
        "Consentimento é obrigatório e pode ser retirado a qualquer momento.",
        "Entrar no grupo não significa interesse ou disponibilidade para encontros.",
        "Nunca compartilhe imagens, contatos ou conversas sem autorização.",
        "Não toleramos assédio, abordagem insistente, discurso de ódio ou exposição.",
        "Qualquer referência sexualizada a menores é proibida e será denunciada.",
        "Divulgação comercial só acontece com autorização da moderação."
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                hero
                rulesList
                acceptCard
            }
            .padding(20)
        }
        .background(SwingTheme.Palette.background)
        .navigationTitle("Comunidade")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 10) {
            Eyebrow(text: "Antes de entrar")
            Text("Liberdade começa com respeito.")
                .font(.title2.weight(.bold).leading(.tight))
                .foregroundStyle(SwingTheme.Palette.textPrimary)
            Text("Esta é uma comunidade para adultos que valorizam conversa, discrição e consentimento. Leia com calma antes de decidir.")
                .font(.subheadline)
                .foregroundStyle(SwingTheme.Palette.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var rulesList: some View {
        VStack(spacing: 10) {
            ForEach(Array(rules.enumerated()), id: \.offset) { index, rule in
                HStack(alignment: .top, spacing: 12) {
                    Text(String(format: "%02d", index + 1))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(SwingTheme.Palette.champagne)
                    Text(rule)
                        .font(.subheadline)
                        .foregroundStyle(SwingTheme.Palette.textPrimary)
                    Spacer()
                }
                .padding(16)
                .swingCard()
            }
        }
    }

    private var acceptCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Eyebrow(text: "Entrada consciente")
            Text("Você está no controle.")
                .font(.headline)
                .foregroundStyle(SwingTheme.Palette.textPrimary)
            Text("O grupo é moderado. Se algo ultrapassar seus limites, você pode sair, bloquear e denunciar. A sua privacidade e a de todas as pessoas vêm primeiro.")
                .font(.subheadline)
                .foregroundStyle(SwingTheme.Palette.textSecondary)

            Toggle(isOn: $confirmedAge) {
                Text("Confirmo que tenho 18 anos ou mais.")
                    .font(.subheadline)
                    .foregroundStyle(SwingTheme.Palette.textPrimary)
            }
            .tint(SwingTheme.Palette.brand)

            Toggle(isOn: $acceptedRules) {
                Text("Li e aceito as regras da comunidade.")
                    .font(.subheadline)
                    .foregroundStyle(SwingTheme.Palette.textPrimary)
            }
            .tint(SwingTheme.Palette.brand)

            Button {
                openURL(AppConfig.communityWhatsAppURL)
            } label: {
                Label("Entrar no WhatsApp", systemImage: "arrow.up.right")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!(confirmedAge && acceptedRules))
            .opacity(confirmedAge && acceptedRules ? 1 : 0.45)

            Text("O WhatsApp é liberado somente após a confirmação de maioridade e a leitura das regras.")
                .font(.caption2)
                .foregroundStyle(SwingTheme.Palette.textSecondary)
        }
        .padding(18)
        .swingCard()
    }
}
