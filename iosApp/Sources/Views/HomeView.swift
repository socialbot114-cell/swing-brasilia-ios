import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var catalog: VenueCatalog

    private let starters = [
        "Somos iniciantes",
        "Quero entender as regras",
        "Quero conhecer os lugares",
        "Quero conversar com a comunidade"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    hero
                    intro
                    guidePreview
                    businessBridge
                }
                .frame(maxWidth: .infinity)
            }
            .safeAreaPadding(.bottom, 96)
            .background(SwingTheme.Palette.background)
            .toolbar {
                ToolbarItem(placement: .principal) { Brand() }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            SwingImage.view("hero.png")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 560)
                .clipped()
            LinearGradient(
                colors: [.clear, SwingTheme.Palette.overlay],
                startPoint: .center, endPoint: .bottom
            )
            VStack(alignment: .leading, spacing: 14) {
                Eyebrow(text: "Comunidade liberal · Brasília")
                Text("Brasília além do convencional.")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                Text("Informação, experiências e conexões com respeito e discrição.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                NavigationLink {
                    DirectoryView()
                } label: {
                    Text("Descobrir")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SwingTheme.Palette.brand)
                        .padding(.vertical, 13)
                        .padding(.horizontal, 28)
                        .background(SwingTheme.Palette.background)
                        .clipShape(Capsule())
                }
                NavigationLink {
                    RulesView()
                } label: {
                    Text("Entrar na comunidade ↗")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .topTrailing) {
            Text("18+")
                .font(.caption.weight(.black))
                .foregroundStyle(SwingTheme.Palette.brand)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(SwingTheme.Palette.champagne)
                .clipShape(Capsule())
                .padding(16)
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 18) {
            Eyebrow(text: "Comece no seu ritmo")
            Text("Curiosidade é um bom começo.")
                .font(.title2.weight(.bold).leading(.tight))
                .foregroundStyle(SwingTheme.Palette.textPrimary)
            Text("Não existe uma forma única de viver novas experiências. Existe a forma que respeita você, seu relacionamento e seus limites.")
                .font(.subheadline)
                .foregroundStyle(SwingTheme.Palette.textSecondary)
            VStack(spacing: 10) {
                ForEach(Array(starters.enumerated()), id: \.offset) { index, item in
                    NavigationLink {
                        if index == 2 {
                            DirectoryView()
                        } else {
                            RulesView()
                        }
                    } label: {
                        HStack {
                            Text("0\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(SwingTheme.Palette.champagne)
                            Text(item)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(SwingTheme.Palette.textPrimary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(SwingTheme.Palette.brand)
                        }
                        .padding(16)
                        .swingCard()
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var guidePreview: some View {
        VStack(alignment: .leading, spacing: 18) {
            Eyebrow(text: "Guia local")
            Text("Encontre seu próximo lugar.")
                .font(.title2.weight(.bold).leading(.tight))
                .foregroundStyle(SwingTheme.Palette.textPrimary)
            if let featured = catalog.featuredVenue {
                NavigationLink {
                    VenueDetailView(venue: featured)
                } label: {
                    VenueCard(venue: featured, index: 1)
                }
                .buttonStyle(.plain)
            }
            NavigationLink {
                DirectoryView()
            } label: {
                Text("Ver todos os lugares")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SwingTheme.Palette.brand)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(.horizontal, 20)
    }

    private var businessBridge: some View {
        ZStack(alignment: .bottomLeading) {
            SwingImage.view("architecture-detail.jpg")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 340)
                .clipped()
            LinearGradient(
                colors: [.clear, SwingTheme.Palette.overlay],
                startPoint: .center, endPoint: .bottom
            )
            VStack(alignment: .leading, spacing: 12) {
                Eyebrow(text: "Para casas, eventos e negócios +18")
                Text("O guia conecta pessoas. A tecnologia organiza a operação.")
                    .font(.title3.weight(.bold).leading(.tight))
                    .foregroundStyle(.white)
                NavigationLink {
                    BusinessView()
                } label: {
                    Text("Conhecer soluções ↗")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SwingTheme.Palette.brand)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 22)
                        .background(SwingTheme.Palette.background)
                        .clipShape(Capsule())
                }
            }
            .padding(24)
        }
    }
}

struct VenueCard: View {
    let venue: Venue
    let index: Int

    var body: some View {
        HStack(spacing: 14) {
            if let logo = venue.logo {
                SwingImage.view(logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(SwingTheme.Palette.surfaceMuted)
                    .frame(width: 64, height: 64)
                    .overlay(
                        Text("DF")
                            .font(.caption.weight(.black))
                            .foregroundStyle(SwingTheme.Palette.brand)
                    )
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(venue.category.rawValue.uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(SwingTheme.Palette.champagne)
                Text(venue.name)
                    .font(.headline)
                    .foregroundStyle(SwingTheme.Palette.textPrimary)
                Text("\(venue.region) · DF")
                    .font(.caption)
                    .foregroundStyle(SwingTheme.Palette.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(SwingTheme.Palette.brand)
        }
        .padding(14)
        .swingCard()
    }
}
