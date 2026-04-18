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
        case .other: return "＋"
        }
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
