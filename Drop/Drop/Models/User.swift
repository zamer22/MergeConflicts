import Foundation

// MARK: - User Model
struct User: Identifiable {
    let id: UUID
    var name: String
    var username: String
    var location: String
    var interests: [EventCategory]
    var upcomingEvents: [Event]
    var pastEvents: [Event]
    var publishedEvents: [Event]
    var followerCount: Int
    var followingCount: Int
    var totalEventsAttended: Int

    init(
        id: UUID = UUID(),
        name: String,
        username: String,
        location: String = "Roma Nte, CDMX",
        interests: [EventCategory] = [],
        upcomingEvents: [Event] = [],
        pastEvents: [Event] = [],
        publishedEvents: [Event] = [],
        followerCount: Int = 0,
        followingCount: Int = 0,
        totalEventsAttended: Int = 0
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.location = location
        self.interests = interests
        self.upcomingEvents = upcomingEvents
        self.pastEvents = pastEvents
        self.publishedEvents = publishedEvents
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.totalEventsAttended = totalEventsAttended
    }

    var initial: String { String(name.prefix(1)) }
}

// MARK: - Sample User
extension User {
    static let sample = User(
        name: "Ana Rivera",
        username: "anarivera",
        location: "Roma Nte, CDMX",
        interests: [.music, .art, .market, .workshop],
        upcomingEvents: Event.sampleEvents,
        followerCount: 128,
        followingCount: 87,
        totalEventsAttended: 42
    )
}
