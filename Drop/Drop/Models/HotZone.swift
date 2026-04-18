import Foundation
import CoreLocation
import MapKit
import SwiftUI

enum HotZoneMomentum {
    case peaking
    case rising
    case steady

    nonisolated var label: String {
        switch self {
        case .peaking: return "Pico"
        case .rising: return "Subiendo"
        case .steady: return "Constante"
        }
    }
}

struct HotZoneObservation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let locationName: String
    let startedAt: Date
    let attendeeCount: Int
    let category: EventCategory
    let isLiveSignal: Bool
}

struct HotZone: Identifiable {
    let id = UUID()
    let title: String
    let coordinate: CLLocationCoordinate2D
    let radiusMeters: CLLocationDistance
    let intensity: Double
    let confidence: Double
    let expectedCrowd: Int
    let bestWindow: String
    let topCategories: [EventCategory]
    let liveEventCount: Int
    let supportingSignals: Int
    let momentum: HotZoneMomentum
    var insight: String?

    var heatOuterColor: Color {
        Color(hex: "#FF7A45").opacity(0.10 + intensity * 0.14)
    }

    var heatMidColor: Color {
        Color(hex: "#FF5A3C").opacity(0.18 + intensity * 0.18)
    }

    var heatCoreColor: Color {
        Color(hex: "#FFB347").opacity(0.26 + intensity * 0.22)
    }

    nonisolated var confidenceLabel: String {
        "\(Int(confidence * 100))% match"
    }

    nonisolated var categoriesLabel: String {
        let labels = topCategories.prefix(2).map(\.rawValue)
        return labels.isEmpty ? "Actividad variada" : labels.joined(separator: " · ")
    }

    nonisolated var fallbackInsight: String {
        let activityText: String
        switch momentum {
        case .peaking:
            activityText = "ya va entrando en pico"
        case .rising:
            activityText = "viene subiendo"
        case .steady:
            activityText = "se mantiene constante"
        }

        return "\(title) suele moverse fuerte entre \(bestWindow) y \(activityText), con mejor respuesta en \(categoriesLabel.lowercased())."
    }
}
