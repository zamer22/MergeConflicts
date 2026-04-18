import Foundation
import CoreLocation

// MARK: - Event Category
enum EventCategory: String, CaseIterable, Identifiable {
    case music = "Música"
    case fair = "Feria"
    case art = "Arte"
    case food = "Comida"
    case sport = "Deporte"
    case market = "Mercado"
    case workshop = "Taller"
    case bar = "Bar"
    case gym = "Gym"
    case other = "Otro"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .music: return "🎵"
        case .fair: return "🎪"
        case .art: return "🎨"
        case .food: return "🍴"
        case .sport: return "🏃"
        case .market: return "🛒"
        case .workshop: return "📚"
        case .bar: return "🍺"
        case .gym: return "💪"
        case .other: return "＋"
        }
    }

    var backendKey: String {
        switch self {
        case .music: return "musica"
        case .fair: return "feria"
        case .art: return "arte"
        case .food: return "comida"
        case .sport: return "deporte"
        case .market: return "mercado"
        case .workshop: return "taller"
        case .bar: return "bar"
        case .gym: return "gym"
        case .other: return "otro"
        }
    }

    static func from(backendKey: String) -> EventCategory {
        return EventCategory.allCases.first { $0.backendKey == backendKey } ?? .other
    }
}

// MARK: - Event Status
enum EventStatus: Equatable {
    case live
    case upcoming(minutesAway: Int)
    case today
    case weekend
}

// MARK: - Event Model
struct Event: Identifiable {
    let id: UUID
    var title: String
    var category: EventCategory
    var location: String
    var distanceMeters: Double
    var startTime: Date
    var endTime: Date?
    var isFree: Bool
    var tags: [String]
    var attendeeCount: Int
    var rating: Double
    var reviewCount: Int
    var status: EventStatus
    var aiSummary: String?
    var reviews: [Review]

    init(
        id: UUID = UUID(),
        title: String,
        category: EventCategory,
        location: String,
        distanceMeters: Double,
        startTime: Date = Date(),
        endTime: Date? = nil,
        isFree: Bool = true,
        tags: [String] = [],
        attendeeCount: Int = 0,
        rating: Double = 0,
        reviewCount: Int = 0,
        status: EventStatus = .live,
        aiSummary: String? = nil,
        reviews: [Review] = []
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.location = location
        self.distanceMeters = distanceMeters
        self.startTime = startTime
        self.endTime = endTime
        self.isFree = isFree
        self.tags = tags
        self.attendeeCount = attendeeCount
        self.rating = rating
        self.reviewCount = reviewCount
        self.status = status
        self.aiSummary = aiSummary
        self.reviews = reviews
    }

    // Mapeo desde el DTO del backend
    init(from dto: RallyDTO, userLocation: CLLocation?) {
        self.id = UUID(uuidString: dto.id) ?? UUID()
        self.title = dto.title
        self.category = EventCategory.from(backendKey: dto.category ?? "otro")
        self.location = dto.venues?.name ?? dto.venues?.address ?? "Monterrey, MX"
        self.startTime = dto.startsAt
        self.endTime = dto.expiresAt
        self.isFree = (dto.entryFee ?? 0) == 0
        self.tags = dto.tags ?? []
        self.attendeeCount = 0
        self.rating = 0
        self.reviewCount = 0
        self.aiSummary = nil
        self.reviews = []

        if let userLoc = userLocation {
            let rallyLoc = CLLocation(latitude: dto.lat, longitude: dto.lng)
            self.distanceMeters = userLoc.distance(from: rallyLoc)
        } else {
            self.distanceMeters = 0
        }

        let now = Date()
        if dto.startsAt <= now {
            self.status = .live
        } else {
            let minutes = Int(dto.startsAt.timeIntervalSince(now) / 60)
            self.status = .upcoming(minutesAway: minutes)
        }
    }
}

// MARK: - Review Model
struct Review: Identifiable {
    let id: UUID
    let authorName: String
    let authorInitial: String
    let stars: Int
    let text: String

    init(id: UUID = UUID(), authorName: String, stars: Int, text: String) {
        self.id = id
        self.authorName = authorName
        self.authorInitial = String(authorName.prefix(1))
        self.stars = stars
        self.text = text
    }

    init(from dto: ReviewDTO) {
        self.id = UUID(uuidString: dto.id) ?? UUID()
        self.authorName = dto.users?.username ?? "Anónimo"
        self.authorInitial = String((dto.users?.username ?? "A").prefix(1))
        self.stars = dto.stars
        self.text = dto.text ?? ""
    }
}

// MARK: - Sample Data
extension Event {
    static let sampleEvents: [Event] = [
        Event(
            title: "Feria de las Flores",
            category: .fair,
            location: "Plaza de la Ciudadela",
            distanceMeters: 400,
            endTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()),
            isFree: true,
            tags: ["#feria", "#artesanal", "#familiar"],
            attendeeCount: 87,
            rating: 4.6,
            reviewCount: 47,
            status: .live,
            aiSummary: "Gente destaca los puestos de plantas raras y el ambiente tranquilo. Mencionan que se llena después de las 16h.",
            reviews: [
                Review(authorName: "Sofía R.", stars: 5, text: "Encontré plantas que no se ven por ningún lado. Volveré sin dudarlo."),
                Review(authorName: "Mario L.", stars: 4, text: "Buen ambiente pero hay que llegar temprano, después se llena mucho."),
                Review(authorName: "Ana P.", stars: 5, text: "Los vendedores son muy amables. Solo llevan efectivo.")
            ]
        ),
        Event(
            title: "Jam session abierta",
            category: .music,
            location: "Parque México",
            distanceMeters: 200,
            endTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()),
            isFree: true,
            tags: ["Música", "Gratis"],
            attendeeCount: 14,
            rating: 4.8,
            reviewCount: 22,
            status: .live
        ),
        Event(
            title: "Mercado de diseñadores",
            category: .market,
            location: "Monumento a la Revolución",
            distanceMeters: 1200,
            isFree: false,
            tags: ["Feria", "Econ. circular"],
            attendeeCount: 87,
            rating: 4.5,
            reviewCount: 30,
            status: .upcoming(minutesAway: 1440)
        )
    ]
}
