import Foundation
import CoreLocation

#if canImport(FoundationModels)
import FoundationModels
#endif

struct HotZoneEngine {
    private let calendar = Calendar(identifier: .gregorian)
    private let cellSizeMeters = 420.0

    func generateHotZones(
        currentEvents: [Event],
        historicalEvents: [Event],
        referenceDate: Date = .now
    ) -> [HotZone] {
        let liveSignals = currentEvents.compactMap(makeLiveObservation(from:))
        let realHistory = historicalEvents.compactMap(makeHistoricalObservation(from:))
        let seededHistory = syntheticHistory(currentEvents: currentEvents, existingHistoryCount: realHistory.count, referenceDate: referenceDate)
        let signals = liveSignals + realHistory + seededHistory

        guard !signals.isEmpty else { return [] }

        let groupedSignals = Dictionary(grouping: signals, by: cellKey(for:))
        let scoredGroups = groupedSignals.compactMap { _, group -> ScoredZone? in
            scoreZone(group, referenceDate: referenceDate)
        }

        guard let maxScore = scoredGroups.map(\.rawScore).max(), maxScore > 0 else {
            return []
        }

        return scoredGroups
            .map { group in
                let normalizedIntensity = min(1, max(0.16, sqrt(group.rawScore / maxScore)))
                return HotZone(
                    title: group.title,
                    coordinate: group.coordinate,
                    radiusMeters: 240 + normalizedIntensity * 360,
                    intensity: normalizedIntensity,
                    confidence: group.confidence,
                    expectedCrowd: group.expectedCrowd,
                    bestWindow: group.bestWindow,
                    topCategories: group.topCategories,
                    liveEventCount: group.liveEventCount,
                    supportingSignals: group.supportingSignals,
                    momentum: group.momentum,
                    insight: nil
                )
            }
            .sorted { lhs, rhs in
                if lhs.intensity == rhs.intensity {
                    return lhs.confidence > rhs.confidence
                }
                return lhs.intensity > rhs.intensity
            }
            .prefix(4)
            .map { $0 }
    }

    private func scoreZone(_ observations: [HotZoneObservation], referenceDate: Date) -> ScoredZone? {
        guard !observations.isEmpty else { return nil }

        let coordinate = averageCoordinate(for: observations)
        let rawScore = observations.reduce(0) { partial, observation in
            partial + weightedSignalScore(for: observation, referenceDate: referenceDate)
        }

        let liveSignals = observations.filter(\.isLiveSignal)
        let weightedHours = observations.map { observation in
            (
                hour: calendar.component(.hour, from: observation.startedAt),
                weight: weightedSignalScore(for: observation, referenceDate: referenceDate)
            )
        }

        let rankedCategories = Dictionary(grouping: observations, by: \.category)
            .mapValues { group in
                group.reduce(0) { partial, observation in
                    partial + weightedSignalScore(for: observation, referenceDate: referenceDate)
                }
            }
            .sorted { $0.value > $1.value }
            .map(\.key)

        let expectedCrowd = max(
            12,
            Int(observations.reduce(0) { partial, observation in
                let weight = observation.isLiveSignal ? 1.1 : 0.45
                return partial + Double(observation.attendeeCount) * weight
            } / Double(max(1, observations.count / 2)))
        )

        let confidence = min(
            0.97,
            0.28
                + Double(min(observations.count, 12)) * 0.035
                + Double(min(liveSignals.count, 3)) * 0.08
        )

        let weightedCenterHour = weightedHours.reduce(0.0) { $0 + Double($1.hour) * $1.weight }
            / max(0.001, weightedHours.reduce(0.0) { $0 + $1.weight })
        let centerHour = Int(weightedCenterHour.rounded()) % 24

        let liveWeight = liveSignals.reduce(0.0) { $0 + Double($1.attendeeCount) }
        let historyWeight = max(
            1,
            observations.filter { !$0.isLiveSignal }.reduce(0.0) { $0 + Double($1.attendeeCount) }
        )
        let momentum: HotZoneMomentum
        if liveWeight > historyWeight * 0.45 {
            momentum = .peaking
        } else if circularHourDistance(centerHour, calendar.component(.hour, from: referenceDate)) <= 2 {
            momentum = .rising
        } else {
            momentum = .steady
        }

        let dominantLocation = observations
            .map(\.locationName)
            .reduce(into: [:]) { counts, value in counts[value, default: 0] += 1 }
            .max(by: { $0.value < $1.value })?
            .key ?? "Zona activa"

        return ScoredZone(
            title: shortLocationName(from: dominantLocation),
            coordinate: coordinate,
            rawScore: rawScore,
            confidence: confidence,
            expectedCrowd: expectedCrowd,
            bestWindow: windowLabel(centerHour: centerHour),
            topCategories: Array(rankedCategories.prefix(2)),
            liveEventCount: liveSignals.count,
            supportingSignals: observations.count,
            momentum: momentum
        )
    }

    private func weightedSignalScore(for observation: HotZoneObservation, referenceDate: Date) -> Double {
        let eventHour = calendar.component(.hour, from: observation.startedAt)
        let currentHour = calendar.component(.hour, from: referenceDate)
        let hourDelta = circularHourDistance(eventHour, currentHour)
        let hourWeight = max(0.12, exp(-pow(Double(hourDelta), 2) / 7.5))

        let sameWeekday = calendar.component(.weekday, from: observation.startedAt)
            == calendar.component(.weekday, from: referenceDate)
        let weekdayWeight = sameWeekday ? 1.18 : 0.82

        let daysAgo = max(0, calendar.dateComponents([.day], from: observation.startedAt, to: referenceDate).day ?? 0)
        let recencyWeight = observation.isLiveSignal ? 1.4 : max(0.45, 1.08 - (Double(daysAgo) / 42.0))
        let crowdWeight = log1p(Double(max(observation.attendeeCount, 6)))

        return crowdWeight * hourWeight * weekdayWeight * recencyWeight
    }

    private func makeLiveObservation(from event: Event) -> HotZoneObservation? {
        guard let coordinate = event.coordinate else { return nil }
        return HotZoneObservation(
            coordinate: coordinate,
            locationName: event.location,
            startedAt: event.startTime,
            attendeeCount: max(event.attendeeCount, 10),
            category: event.category,
            isLiveSignal: true
        )
    }

    private func makeHistoricalObservation(from event: Event) -> HotZoneObservation? {
        guard let coordinate = event.coordinate else { return nil }
        return HotZoneObservation(
            coordinate: coordinate,
            locationName: event.location,
            startedAt: event.startTime,
            attendeeCount: max(event.attendeeCount, 8),
            category: event.category,
            isLiveSignal: false
        )
    }

    private func syntheticHistory(
        currentEvents: [Event],
        existingHistoryCount: Int,
        referenceDate: Date
    ) -> [HotZoneObservation] {
        guard !currentEvents.isEmpty else { return [] }

        let syntheticWeeks = existingHistoryCount >= 8 ? 2 : 6
        return currentEvents.compactMap { event in
            event.coordinate.map { (event, $0) }
        }
        .flatMap { event, coordinate in
            (1...syntheticWeeks).compactMap { week in
                let baseHour = preferredHour(for: event, referenceDate: referenceDate)
                let jitterMinutes = Int(((unitValue("\(event.id.uuidString)-week-\(week)-minute") - 0.5) * 110).rounded())

                guard
                    let weekDate = calendar.date(byAdding: .day, value: -(week * 7), to: referenceDate),
                    let alignedDate = calendar.date(
                        bySettingHour: baseHour,
                        minute: 0,
                        second: 0,
                        of: weekDate
                    ),
                    let startedAt = calendar.date(byAdding: .minute, value: jitterMinutes, to: alignedDate)
                else {
                    return nil
                }

                let northMeters = (unitValue("\(event.id.uuidString)-week-\(week)-north") - 0.5) * 260
                let eastMeters = (unitValue("\(event.id.uuidString)-week-\(week)-east") - 0.5) * 260
                let variedCoordinate = offsetCoordinate(
                    coordinate,
                    northMeters: northMeters,
                    eastMeters: eastMeters
                )

                let crowdScale = 0.7 + (unitValue("\(event.id.uuidString)-week-\(week)-crowd") * 0.8)
                return HotZoneObservation(
                    coordinate: variedCoordinate,
                    locationName: event.location,
                    startedAt: startedAt,
                    attendeeCount: max(8, Int(Double(max(event.attendeeCount, 18)) * crowdScale)),
                    category: event.category,
                    isLiveSignal: false
                )
            }
        }
    }

    private func preferredHour(for event: Event, referenceDate: Date) -> Int {
        let fallbackHour = calendar.component(.hour, from: event.startTime)

        switch event.category {
        case .music, .bar:
            return 20
        case .food, .fair, .market:
            return 18
        case .sport, .gym:
            return 19
        case .art, .workshop:
            return 17
        case .other:
            return max(fallbackHour, calendar.component(.hour, from: referenceDate))
        }
    }

    private func windowLabel(centerHour: Int) -> String {
        let start = normalizedHour(centerHour - 1)
        let end = normalizedHour(centerHour + 1)
        return "\(hourLabel(start))–\(hourLabel(end))"
    }

    private func hourLabel(_ hour: Int) -> String {
        let normalized = normalizedHour(hour)
        let suffix = normalized >= 12 ? "pm" : "am"
        let displayHour = normalized == 0 ? 12 : (normalized > 12 ? normalized - 12 : normalized)
        return "\(displayHour)\(suffix)"
    }

    private func normalizedHour(_ hour: Int) -> Int {
        (hour % 24 + 24) % 24
    }

    private func circularHourDistance(_ lhs: Int, _ rhs: Int) -> Int {
        let diff = abs(lhs - rhs)
        return min(diff, 24 - diff)
    }

    private func averageCoordinate(for observations: [HotZoneObservation]) -> CLLocationCoordinate2D {
        let count = Double(observations.count)
        let latitude = observations.reduce(0.0) { $0 + $1.coordinate.latitude } / count
        let longitude = observations.reduce(0.0) { $0 + $1.coordinate.longitude } / count
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    private func cellKey(for observation: HotZoneObservation) -> String {
        let latMeters = observation.coordinate.latitude * 111_320
        let lonMeters = observation.coordinate.longitude
            * max(1.0, cos(observation.coordinate.latitude * .pi / 180) * 111_320)
        let x = Int((lonMeters / cellSizeMeters).rounded())
        let y = Int((latMeters / cellSizeMeters).rounded())
        return "\(x)-\(y)"
    }

    private func offsetCoordinate(
        _ coordinate: CLLocationCoordinate2D,
        northMeters: Double,
        eastMeters: Double
    ) -> CLLocationCoordinate2D {
        let latitudeDelta = northMeters / 111_320
        let longitudeDelta = eastMeters / max(1.0, cos(coordinate.latitude * .pi / 180) * 111_320)

        return CLLocationCoordinate2D(
            latitude: coordinate.latitude + latitudeDelta,
            longitude: coordinate.longitude + longitudeDelta
        )
    }

    private func shortLocationName(from location: String) -> String {
        location
            .components(separatedBy: "·")
            .first?
            .components(separatedBy: ",")
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nonEmpty ?? "Zona activa"
    }

    private func unitValue(_ seed: String) -> Double {
        var hash: UInt64 = 1469598103934665603
        for byte in seed.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }
        return Double(hash % 10_000) / 10_000
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}

private struct ScoredZone {
    let title: String
    let coordinate: CLLocationCoordinate2D
    let rawScore: Double
    let confidence: Double
    let expectedCrowd: Int
    let bestWindow: String
    let topCategories: [EventCategory]
    let liveEventCount: Int
    let supportingSignals: Int
    let momentum: HotZoneMomentum
}

actor AppleHotZoneNarrator {
    static let shared = AppleHotZoneNarrator()

    func insight(for zone: HotZone, referenceDate: Date = .now) async -> String? {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let model = SystemLanguageModel.default
            guard model.isAvailable else { return nil }

            let instructions = """
            Eres un analista de actividad urbana para una app llamada Drop.
            Responde siempre en español de México.
            Devuelve exactamente una sola frase breve, concreta y accionable.
            Explica el patrón histórico de la zona y por qué está activa ahorita.
            No uses viñetas, títulos, comillas ni advertencias.
            """

            let session = LanguageModelSession(instructions: instructions)
            let hourFormatter = DateFormatter()
            hourFormatter.locale = Locale(identifier: "es_MX")
            hourFormatter.dateFormat = "h:mm a"

            let prompt = """
            Zona: \(zone.title)
            Hora local actual: \(hourFormatter.string(from: referenceDate))
            Franja histórica fuerte: \(zone.bestWindow)
            Categorías que más jalan gente: \(zone.categoriesLabel)
            Crowd esperado: \(zone.expectedCrowd) personas
            Señales en vivo: \(zone.liveEventCount)
            Confianza: \(Int(zone.confidence * 100))%
            Momentum: \(zone.momentum.label)
            """

            do {
                let response = try await session.respond(to: prompt)
                let cleaned = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
                return cleaned.isEmpty ? nil : cleaned
            } catch {
                return nil
            }
        }
        #endif

        return nil
    }
}
