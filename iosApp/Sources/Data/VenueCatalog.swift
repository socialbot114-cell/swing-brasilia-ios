import Combine
import Foundation

struct VenuePayload: Codable {
    let version: Int
    let venues: [Venue]
}

enum VenueFilter: String, CaseIterable, Identifiable {
    case all = "Todos"
    case houses = "Casas"
    case motels = "Motéis"
    case shops = "Sex shops"
    case newcomers = "Iniciantes"

    var id: String { rawValue }
}

final class VenueCatalog: ObservableObject {
    @Published private(set) var venues: [Venue]

    init(venues: [Venue]) {
        self.venues = venues
    }

    convenience init() {
        self.init(venues: VenueCatalog.loadBundled())
    }

    func venue(slug: String) -> Venue? {
        venues.first { $0.slug == slug }
    }

    var featuredVenue: Venue? {
        venues.first { $0.isSponsored } ?? venues.first { $0.featured }
    }

    func filtered(query: String, filter: VenueFilter) -> [Venue] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let matched = venues.filter { venue in
            if !trimmed.isEmpty {
                let haystack = "\(venue.name) \(venue.region) \(venue.category.rawValue)".lowercased()
                guard haystack.contains(trimmed) else { return false }
            }
            switch filter {
            case .all:
                return true
            case .houses:
                return venue.category == .casa
            case .motels:
                return venue.category == .motel
            case .shops:
                return venue.category == .sexShop
            case .newcomers:
                return venue.newcomerFriendly
            }
        }
        return matched.sorted {
            if $0.isSponsored != $1.isSponsored { return $0.isSponsored }
            return $0.name < $1.name
        }
    }

    static func loadBundled() -> [Venue] {
        guard let url = Bundle.main.url(forResource: "venues", withExtension: "json") else {
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(VenuePayload.self, from: data).venues
        } catch {
            return []
        }
    }
}
