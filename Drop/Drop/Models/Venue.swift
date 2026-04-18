import Foundation

struct Venue: Codable, Identifiable {
    let id: UUID
    let name: String
    let address: String
    let lat: Double
    let lng: Double
    let category: String?
    let isSponsor: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, address, lat, lng, category
        case isSponsor = "is_sponsor"
        case createdAt = "created_at"
    }
}
