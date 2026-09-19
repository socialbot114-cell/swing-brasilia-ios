import SwiftUI

struct VenueDetailView: View {
    @Environment(\.openURL) private var openURL
    let venue: Venue

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                gallery
                bodyContent
            }
        }
        .background(SwingTheme.Palette.background)
        .navigationTitle(venue.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 14) {
            if let logo = venue.logo {
                SwingImage.view(logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 140)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(SwingTheme.Palette.surfaceMuted)
                    .frame(height: 140)
                    .overlay(
                        Text("REGISTRO\nDF")
                            .font(.caption.weight(.black))
                            .foregroundStyle(SwingTheme.Palette.brand)
                            .multilineTextAlignment(.center)
                    )
            }
            VStack(spacing: 6) {
                Text("\(venue.category.rawValue) · \(venue.region)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SwingTheme.Palette.champagne)
                Text(venue.name)
                    .font(.title2.weight(.bold).leading(.tight))
                    .foregroundStyle(SwingTheme.Palette.textPrimary)
                    .multilineTextAlignment(.center)
                HStack(spacing: 6) {
                    Text(venue.status)
                    Text("·")
                    Text("Atualizado em \(venue.updatedAt)")
                }
                .font(.caption2)
                .foregroundStyle(SwingTheme.Palette.textSecondary)
            }
            if let sponsor = venue.sponsorLabel {
                Text(sponsor.uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(SwingTheme.Palette.brand)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(SwingTheme.Palette.brandSoft)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var gallery: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(venue.gallery, id: \.self) { filename in
                    SwingImage.view(filename)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 220, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var bodyContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Antes de ir")
                    .font(.headline)
                    .foregroundStyle(SwingTheme.Palette.textPrimary)
                Text(venue.summary)
                    .font(.subheadline)
                    .foregroundStyle(SwingTheme.Palette.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .swingCard()

            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(venue.notes.enumerated()), id: \.offset) { index, note in
                    HStack(alignment: .top, spacing: 10) {
                        Text("0\(index + 1)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(SwingTheme.Palette.champagne)
                        Text(note)
                            .font(.subheadline)
                            .foregroundStyle(SwingTheme.Palette.textPrimary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .swingCard()

            VStack(alignment: .leading, spacing: 14) {
                Text("FICHA DO LOCAL")
                    .font(.caption2.weight(.bold))
                    .tracking(1.4)
                    .foregroundStyle(SwingTheme.Palette.champagne)
                detailRow("Região", "\(venue.region), DF")
                detailRow("Categoria", venue.category.rawValue)
                detailRow("Coordenada", "Aproximada por região")
                detailRow("Fonte", venue.sourceLabel)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .swingCard()

            Button {
                if let url = URL(string: venue.sourceUrl) {
                    openURL(url)
                }
            } label: {
                Text("Consultar fonte pública ↗")
            }
            .buttonStyle(PrimaryButtonStyle())

            Button {
                if let url = URL(string: "mailto:\(AppConfig.contactEmail)?subject=Correção de informações") {
                    openURL(url)
                }
            } label: {
                Text("Solicitar correção")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(SwingTheme.Palette.brand)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(SwingTheme.Palette.textSecondary)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(SwingTheme.Palette.textPrimary)
            Spacer()
        }
    }
}
