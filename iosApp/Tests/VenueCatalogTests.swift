import XCTest
@testable import SwingBrasilia

final class VenueCatalogTests: XCTestCase {

    private var catalog: VenueCatalog!

    override func setUp() {
        super.setUp()
        catalog = VenueCatalog(venues: Self.decode(Self.fixtureJSON))
    }

    func testDecodesBundledCatalog() throws {
        let venues = VenueCatalog.loadBundled()
        if venues.isEmpty {
            throw XCTSkip("Catálogo empacotado indisponível neste contexto de teste")
        }
        XCTAssertEqual(venues.count, 25)
        XCTAssertTrue(venues.contains { $0.slug == "zeus-night-club" })
        XCTAssertTrue(venues.contains { $0.slug == "fun-haus-club" })
    }

    func testAllVenuesHaveUniqueSlugs() {
        let slugs = catalog.venues.map(\.slug)
        XCTAssertEqual(Set(slugs).count, slugs.count)
    }

    func testFilterByCategory() {
        XCTAssertEqual(catalog.filtered(query: "", filter: .houses).map(\.slug), ["zeus-night-club", "fun-haus-club"])
        XCTAssertEqual(catalog.filtered(query: "", filter: .motels).map(\.slug), ["colorado"])
        XCTAssertEqual(catalog.filtered(query: "", filter: .shops).map(\.slug), ["erotika-asa-sul"])
        XCTAssertEqual(catalog.filtered(query: "", filter: .newcomers).map(\.slug), ["zeus-night-club", "fun-haus-club"])
    }

    func testFilterByQueryIsCaseInsensitive() {
        XCTAssertEqual(catalog.filtered(query: "ZEUS", filter: .all).map(\.slug), ["zeus-night-club"])
        XCTAssertEqual(catalog.filtered(query: "asa sul", filter: .shops).map(\.slug), ["erotika-asa-sul"])
    }

    func testFeaturedVenueIsSponsoredFirst() {
        XCTAssertEqual(catalog.featuredVenue?.slug, "fun-haus-club")
    }

    func testVenueLookupBySlug() {
        XCTAssertEqual(catalog.venue(slug: "zeus-night-club")?.name, "Zeus Night Club")
        XCTAssertNil(catalog.venue(slug: "nao-existe"))
    }

    private static let fixtureJSON = """
    {
      "version": 1,
      "venues": [
        {
          "slug": "zeus-night-club",
          "name": "Zeus Night Club",
          "region": "Águas Claras",
          "area": "Brasília, DF",
          "category": "Casa liberal",
          "summary": "Registro editorial.",
          "coordinates": { "latitude": -15.8398, "longitude": -48.0281 },
          "logo": "zeus-logo.png",
          "theme": "red",
          "status": "Informação pública",
          "updatedAt": "11 de setembro de 2026",
          "sourceLabel": "Pesquisa pública",
          "sourceUrl": "https://example.com",
          "newcomerFriendly": true,
          "gallery": ["night-atmosphere.jpg"],
          "editorialSignals": ["Informação pública"],
          "notes": ["Nota."]
        },
        {
          "slug": "fun-haus-club",
          "name": "Fun Haus Club",
          "region": "SAAN",
          "area": "Brasília, DF",
          "category": "Casa liberal",
          "summary": "Registro editorial.",
          "coordinates": { "latitude": -15.7615, "longitude": -47.9477 },
          "logo": "fun-haus-logo.jpg",
          "theme": "ivory",
          "status": "Informação pública",
          "updatedAt": "11 de setembro de 2026",
          "sourceLabel": "Pesquisa pública",
          "sourceUrl": "https://example.com",
          "newcomerFriendly": true,
          "gallery": ["night-atmosphere.jpg"],
          "editorialSignals": ["Informação pública"],
          "notes": ["Nota."],
          "featured": true,
          "isSponsored": true,
          "sponsorLabel": "Anúncio"
        },
        {
          "slug": "colorado",
          "name": "Colorado",
          "region": "Sobradinho / Colorado",
          "area": "Brasília, DF",
          "category": "Motel e suíte",
          "summary": "Registro público.",
          "coordinates": { "latitude": -15.65, "longitude": -47.75 },
          "theme": "red",
          "status": "Informação pública",
          "updatedAt": "11 de setembro de 2026",
          "sourceLabel": "Pesquisa pública",
          "sourceUrl": "https://example.com",
          "newcomerFriendly": false,
          "gallery": ["night-atmosphere.jpg"],
          "editorialSignals": ["Não verificado"],
          "notes": ["Nota."]
        },
        {
          "slug": "erotika-asa-sul",
          "name": "Erotika Sex Shop Asa Sul",
          "region": "Asa Sul",
          "area": "Brasília, DF",
          "category": "Sex shop e boutique",
          "summary": "Registro público.",
          "coordinates": { "latitude": -15.81, "longitude": -47.91 },
          "theme": "red",
          "status": "Informação pública",
          "updatedAt": "11 de setembro de 2026",
          "sourceLabel": "Pesquisa pública",
          "sourceUrl": "https://example.com",
          "newcomerFriendly": false,
          "gallery": ["night-atmosphere.jpg"],
          "editorialSignals": ["Não verificado"],
          "notes": ["Nota."]
        }
      ]
    }
    """

    private static func decode(_ json: String) -> [Venue] {
        let data = json.data(using: .utf8)!
        return (try? JSONDecoder().decode(VenuePayload.self, from: data).venues) ?? []
    }
}
