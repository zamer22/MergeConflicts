import Foundation

struct Rally: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String?
    let venueId: UUID?
    let creatorId: UUID?
    let entryFee: Int
    let maxParticipants: Int
    let startsAt: Date
    let expiresAt: Date
    let status: String
    let lat: Double
    let lng: Double
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, description, status, lat, lng
        case venueId = "venue_id"
        case creatorId = "creator_id"
        case entryFee = "entry_fee"
        case maxParticipants = "max_participants"
        case startsAt = "starts_at"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
    }

    var isActive: Bool { status == "active" && expiresAt > Date() }

    var timeRemainingText: String {
        let minutes = Int(expiresAt.timeIntervalSinceNow / 60)
        if minutes < 60 { return "\(minutes)min" }
        return "\(minutes / 60)h \(minutes % 60)min"
    }
}

struct RallyParticipant: Codable, Identifiable {
    let id: UUID
    let rallyId: UUID
    let userId: UUID
    let joinedAt: Date
    let paymentStatus: String
    let cancelledAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case rallyId = "rally_id"
        case userId = "user_id"
        case joinedAt = "joined_at"
        case paymentStatus = "payment_status"
        case cancelledAt = "cancelled_at"
    }
}
