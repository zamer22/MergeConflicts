import Foundation

struct AppUser: Codable, Identifiable {
    let id: UUID
    let email: String
    let username: String
    let avatarUrl: String?
    let rallyScore: Int
    let ralliesAttended: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, email, username
        case avatarUrl = "avatar_url"
        case rallyScore = "rally_score"
        case ralliesAttended = "rallies_attended"
        case createdAt = "created_at"
    }
}
