import Foundation
import CoreLocation

// MARK: - API Client

final class APIClient {
    static let shared = APIClient()
    private init() {}

    // Cambia a tu URL de Render cuando lo despliegues
    let baseURL = "http://localhost:8000"

    private func makeDecoder() -> JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            var str = try container.decode(String.self)
            // Supabase devuelve timestamps sin timezone — tratamos como UTC
            if str.contains("T") && !str.hasSuffix("Z") && !str.contains("+") {
                str += "Z"
            }
            let full = ISO8601DateFormatter()
            full.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let d = full.date(from: str) { return d }
            full.formatOptions = [.withInternetDateTime]
            if let d = full.date(from: str) { return d }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Fecha inválida: \(str)")
        }
        return d
    }

    private func makeEncoder() -> JSONEncoder {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }

    func get<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: baseURL + path) else { throw URLError(.badURL) }
        let (data, response) = try await URLSession.shared.data(from: url)
        try checkStatus(response, data: data)
        return try makeDecoder().decode(T.self, from: data)
    }

    func post<Body: Encodable, Response: Decodable>(_ path: String, body: Body) async throws -> Response {
        guard let url = URL(string: baseURL + path) else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try makeEncoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: req)
        try checkStatus(response, data: data)
        return try makeDecoder().decode(Response.self, from: data)
    }

    func postVoid<Body: Encodable>(_ path: String, body: Body) async throws {
        guard let url = URL(string: baseURL + path) else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try makeEncoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: req)
        try checkStatus(response, data: data)
    }

    func deleteVoid(_ path: String) async throws {
        guard let url = URL(string: baseURL + path) else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        let (data, response) = try await URLSession.shared.data(for: req)
        try checkStatus(response, data: data)
    }

    private func checkStatus(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200...299).contains(http.statusCode) else {
            if let err = try? JSONDecoder().decode([String: String].self, from: data),
               let detail = err["detail"] {
                throw NSError(domain: "DropAPI", code: http.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: detail])
            }
            throw URLError(.badServerResponse)
        }
    }
}

// MARK: - DTOs

struct RallyDTO: Codable {
    let id: String
    let title: String
    let description: String?
    let venueId: String?
    let creatorId: String?
    let entryFee: Int?
    let maxParticipants: Int?
    let startsAt: Date
    let expiresAt: Date
    let status: String?
    let lat: Double
    let lng: Double
    let category: String?
    let tags: [String]?
    let imageUrl: String?
    let venues: VenuePartialDTO?
}

struct VenuePartialDTO: Codable {
    let name: String
    let address: String?
}

struct VenueDTO: Codable {
    let id: String
    let name: String
    let address: String
    let lat: Double
    let lng: Double
    let category: String?
    let isSponsor: Bool?
}

struct UserDTO: Codable {
    let id: String
    let email: String?
    let username: String
    let avatarUrl: String?
    let rallyScore: Int?
    let ralliesAttended: Int?
    let bio: String?
    let interests: [String]?
    let locationLabel: String?
    let followersCount: Int?
    let followingCount: Int?
}

struct ReviewDTO: Codable {
    let id: String
    let rallyId: String?
    let userId: String?
    let stars: Int
    let text: String?
    let createdAt: Date?
    let users: ReviewUserDTO?
}

struct ReviewUserDTO: Codable {
    let username: String
    let avatarUrl: String?
}

struct StatsDTO: Codable {
    let participants: Int
    let reviewsCount: Int
    let avgRating: Double?
}

struct AISummaryDTO: Codable {
    let summary: String
    let tags: [String]?
}

struct RecommendationsDTO: Codable {
    let rallies: [RallyDTO]
    let reason: String
}

// MARK: - Request Bodies

struct JoinBody: Codable {
    let rallyId: String
    let userId: String
}

struct CancelBody: Codable {
    let rallyId: String
    let userId: String
}

struct CreateUserBody: Codable {
    let id: String
    let email: String
    let username: String
    let interests: [String]
    let locationLabel: String?
}

struct SaveBody: Codable {
    let rallyId: String
    let userId: String
}

struct CreateRallyRequest: Codable {
    let title: String
    let description: String?
    let creatorId: String
    let entryFee: Int
    let maxParticipants: Int
    let startsAt: String
    let expiresAt: String
    let lat: Double
    let lng: Double
    let category: String
    let tags: [String]
}

// MARK: - Drop Service

@MainActor
final class DropService {
    static let shared = DropService()
    private let api = APIClient.shared
    private init() {}

    // MARK: Rallies

    func fetchRallies(category: String? = nil, search: String? = nil) async throws -> [Event] {
        var path = "/rallies/"
        var params: [String] = []
        if let cat = category { params.append("category=\(cat)") }
        if let s = search, let encoded = s.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            params.append("search=\(encoded)")
        }
        if !params.isEmpty { path += "?" + params.joined(separator: "&") }
        let dtos: [RallyDTO] = try await api.get(path)
        return dtos.map { Event(from: $0, userLocation: nil) }
    }

    func fetchRallyDetail(id: String) async throws -> Event {
        async let rallyDTO: RallyDTO = api.get("/rallies/\(id)")
        async let reviewDTOs: [ReviewDTO] = api.get("/rallies/\(id)/reviews")
        async let stats: StatsDTO = api.get("/rallies/\(id)/stats")

        let (rally, reviews, s) = try await (rallyDTO, reviewDTOs, stats)
        var event = Event(from: rally, userLocation: nil)
        event.reviews = reviews.map { Review(from: $0) }
        event.attendeeCount = s.participants
        event.rating = s.avgRating ?? 0
        event.reviewCount = s.reviewsCount
        return event
    }

    func fetchAISummary(rallyId: String) async throws -> AISummaryDTO {
        return try await api.get("/ai/summary/\(rallyId)")
    }

    func joinRally(rallyId: String, userId: String) async throws {
        try await api.postVoid("/participants/join", body: JoinBody(rallyId: rallyId, userId: userId))
    }

    func createRally(_ body: CreateRallyRequest) async throws -> RallyDTO {
        return try await api.post("/rallies/", body: body)
    }

    // MARK: Users

    func createUser(id: String, email: String, username: String) async throws -> UserDTO {
        return try await api.post("/users/", body: CreateUserBody(
            id: id, email: email, username: username, interests: [], locationLabel: nil
        ))
    }

    func fetchUser(id: String) async throws -> UserDTO {
        return try await api.get("/users/\(id)")
    }

    func fetchUpcoming(userId: String) async throws -> [Event] {
        let dtos: [RallyDTO] = try await api.get("/users/\(userId)/upcoming")
        return dtos.map { Event(from: $0, userLocation: nil) }
    }

    func fetchPast(userId: String) async throws -> [Event] {
        let dtos: [RallyDTO] = try await api.get("/users/\(userId)/past")
        return dtos.map { Event(from: $0, userLocation: nil) }
    }

    func fetchRecommendations(userId: String) async throws -> (events: [Event], reason: String) {
        let dto: RecommendationsDTO = try await api.get("/ai/recommendations/\(userId)")
        return (dto.rallies.map { Event(from: $0, userLocation: nil) }, dto.reason)
    }

    // MARK: Saved

    func saveRally(rallyId: String, userId: String) async throws {
        try await api.postVoid("/saved/", body: SaveBody(rallyId: rallyId, userId: userId))
    }

    func unsaveRally(rallyId: String, userId: String) async throws {
        try await api.deleteVoid("/saved/?rally_id=\(rallyId)&user_id=\(userId)")
    }

    func fetchSaved(userId: String) async throws -> [Event] {
        let dtos: [RallyDTO] = try await api.get("/saved/\(userId)")
        return dtos.map { Event(from: $0, userLocation: nil) }
    }
}
