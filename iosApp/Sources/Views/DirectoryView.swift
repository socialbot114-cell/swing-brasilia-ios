import SwiftUI

struct DirectoryView: View {
    @EnvironmentObject private var catalog: VenueCatalog

    @State private var query = ""
    @State private var filter: VenueFilter = .all

    private var results: [Venue] {
        catalog.filtered(query: query, filter: filter)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                notice
                searchBar
                chips
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(results.enumerated()), id: \.element.id) { index, venue in
                            NavigationLink {
                                VenueDetailView(venue: venue)
                            } label: {
                                VenueRow(venue: venue, index: index + 1)
                            }
                            .buttonStyle(.plain)
                        }
                        if results.isEmpty {
                            VStack(spacing: 8) {
                                Text("Nenhum registro encontrado.")
                                    .font(.headline)
                                    .foregroundStyle(SwingTheme.Palette.textPrimary)
                                Text("Tente buscar por outra região ou categoria.")
                                    .font(.subheadline)
                                    .foregroundStyle(SwingTheme.Palette.textSecondary)
                            }
                            .padding(.top, 40)
                        }
                    }
                    .padding(16)
                }
            }
            .background(SwingTheme.Palette.background)
            .navigationTitle("Explore Brasília")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var notice: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(SwingTheme.Palette.champagne)
                .frame(width: 8, height: 8)
            Text("Diretório editorial, não um ranking. Confirme endereço, agenda, valores e regras diretamente com cada estabelecimento.")
                .font(.caption)
                .foregroundStyle(SwingTheme.Palette.textSecondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SwingTheme.Palette.surfaceMuted)
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(SwingTheme.Palette.textSecondary)
            TextField("Nome, região ou categoria", text: $query)
                .font(.subheadline)
        }
        .padding(12)
        .background(SwingTheme.Palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(SwingTheme.Palette.border, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(VenueFilter.allCases) { option in
                    let count = count(for: option)
                    Button {
                        filter = option
                    } label: {
                        HStack(spacing: 6) {
                            Text(option.rawValue)
                            Text("\(count)")
                                .font(.caption2.weight(.bold))
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(filter == option ? .white : SwingTheme.Palette.brand)
                        .padding(.vertical, 9)
                        .padding(.horizontal, 14)
                        .background(filter == option ? SwingTheme.Palette.brand : SwingTheme.Palette.surface)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(SwingTheme.Palette.brand, lineWidth: filter == option ? 0 : 1.2)
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private func count(for filter: VenueFilter) -> Int {
        catalog.filtered(query: "", filter: filter).count
    }
}

struct VenueRow: View {
    let venue: Venue
    let index: Int

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(venue.theme == .red ? SwingTheme.Palette.brand : SwingTheme.Palette.surfaceMuted)
                if let logo = venue.logo {
                    SwingImage.view(logo)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                } else {
                    Text(venue.region.prefix(2).uppercased())
                        .font(.caption.weight(.black))
                        .foregroundStyle(SwingTheme.Palette.background)
                }
            }
            .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(venue.isSponsored ? "Anúncio patrocinado" : venue.status)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(venue.isSponsored ? SwingTheme.Palette.champagne : SwingTheme.Palette.textSecondary)
                    Text("·")
                        .foregroundStyle(SwingTheme.Palette.textSecondary)
                    Text(venue.category.rawValue)
                        .font(.caption2)
                        .foregroundStyle(SwingTheme.Palette.textSecondary)
                }
                Text(venue.name)
                    .font(.headline)
                    .foregroundStyle(SwingTheme.Palette.textPrimary)
                Text(venue.summary)
                    .font(.caption)
                    .foregroundStyle(SwingTheme.Palette.textSecondary)
                    .lineLimit(2)
                Text("\(venue.region) · DF")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(SwingTheme.Palette.brand)
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
