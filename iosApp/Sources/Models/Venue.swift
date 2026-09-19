import Foundation

enum VenueCategory: String, Codable, CaseIterable, Hashable {
    case casa = "Casa liberal"
    case motel = "Motel e suíte"
    case sexShop = "Sex shop e boutique"

    var label: String { rawValue }
}

enum VenueTheme: String, Codable, Hashable {
    case red
    case ivory
}

struct VenueCoordinate: Codable, Hashable {
    let latitude: Double
    let longitude: Double
}

struct Venue: Identifiable, Codable, Hashable {
    let slug: String
    let name: String
    let region: String
    let area: String
    let category: VenueCategory
    let summary: String
    let coordinates: VenueCoordinate
    let logo: String?
    let theme: VenueTheme
    let status: String
    let updatedAt: String
    let sourceLabel: String
    let sourceUrl: String
    let newcomerFriendly: Bool
    let gallery: [String]
    let editorialSignals: [String]
    let notes: [String]
    let featured: Bool
    let isSponsored: Bool
    let sponsorLabel: String?

    var id: String { slug }

    enum CodingKeys: String, CodingKey {
        case slug, name, region, area, category, summary, coordinates
        case logo, theme, status, updatedAt, sourceLabel, sourceUrl
        case newcomerFriendly, gallery, editorialSignals, notes
        case featured, isSponsored, sponsorLabel
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        slug = try container.decode(String.self, forKey: .slug)
        name = try container.decode(String.self, forKey: .name)
        region = try container.decode(String.self, forKey: .region)
        area = try container.decode(String.self, forKey: .area)
        category = try container.decode(VenueCategory.self, forKey: .category)
        summary = try container.decode(String.self, forKey: .summary)
        coordinates = try container.decode(VenueCoordinate.self, forKey: .coordinates)
        logo = try container.decodeIfPresent(String.self, forKey: .logo)
        theme = try container.decode(VenueTheme.self, forKey: .theme)
        status = try container.decode(String.self, forKey: .status)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        sourceLabel = try container.decode(String.self, forKey: .sourceLabel)
        sourceUrl = try container.decode(String.self, forKey: .sourceUrl)
        newcomerFriendly = try container.decode(Bool.self, forKey: .newcomerFriendly)
        gallery = try container.decode([String].self, forKey: .gallery)
        editorialSignals = try container.decode([String].self, forKey: .editorialSignals)
        notes = try container.decode([String].self, forKey: .notes)
        featured = try container.decodeIfPresent(Bool.self, forKey: .featured) ?? false
        isSponsored = try container.decodeIfPresent(Bool.self, forKey: .isSponsored) ?? false
        sponsorLabel = try container.decodeIfPresent(String.self, forKey: .sponsorLabel)
    }
}
