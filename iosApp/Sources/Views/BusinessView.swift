import SwiftUI

struct BusinessView: View {
    @Environment(\.openURL) private var openURL

    private let services: [(title: String, text: String)] = [
        ("Sites e aplicativos", "Portais, landing pages, áreas de membros e aplicativos."),
        ("Chatbots", "Atendimento, programação e direcionamento pelo WhatsApp."),
        ("Reservas", "Listas, convites, capacidade, check-in e promoters."),
        ("CRM e automação", "Membros, segmentação, campanhas e indicadores."),
        ("Pagamentos", "Ingressos, assinaturas, cupons e integrações."),
        ("E-commerce", "Catálogo, produtos, afiliados e conteúdo integrado.")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                hero
                serviceGrid
                cta
            }
            .padding(20)
        }
        .background(SwingTheme.Palette.background)
        .navigationTitle("Tecnologia")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 10) {
            Eyebrow(text: "Tecnologia para negócios +18")
            Text("Uma operação melhor muda toda a experiência.")
                .font(.title2.weight(.bold).leading(.tight))
                .foregroundStyle(SwingTheme.Palette.textPrimary)
            Text("Produto digital e automação para um mercado que exige discrição, agilidade e controle.")
                .font(.subheadline)
                .foregroundStyle(SwingTheme.Palette.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var serviceGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            Eyebrow(text: "Soluções")
            Text("Da entrada ao relacionamento.")
                .font(.headline)
                .foregroundStyle(SwingTheme.Palette.textPrimary)
            VStack(spacing: 10) {
                ForEach(Array(services.enumerated()), id: \.offset) { index, service in
                    HStack(alignment: .top, spacing: 12) {
                        Text(String(format: "%02d", index + 1))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(SwingTheme.Palette.champagne)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(service.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SwingTheme.Palette.textPrimary)
                            Text(service.text)
                                .font(.caption)
                                .foregroundStyle(SwingTheme.Palette.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .swingCard()
                }
            }
        }
    }

    private var cta: some View {
        VStack(spacing: 14) {
            Text("Quero modernizar meu negócio.")
                .font(.headline)
                .foregroundStyle(SwingTheme.Palette.textPrimary)
                .multilineTextAlignment(.center)
            Button {
                openURL(AppConfig.businessWhatsAppURL)
            } label: {
                Label("Iniciar conversa", systemImage: "arrow.up.right")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(18)
        .swingCard()
    }
}
