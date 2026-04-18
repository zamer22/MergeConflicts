import SwiftUI

struct RallyCardView: View {
    let rally: Rally
    let venue: Venue?
    let distanceText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(rally.title)
                        .font(.headline)
                    if let venue {
                        Text(venue.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if venue?.isSponsor == true {
                    Text("SPONSOR")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.yellow.opacity(0.2))
                        .foregroundStyle(.yellow)
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 16) {
                Label("\(rally.entryFee) MXN", systemImage: "creditcard")
                Label(rally.timeRemainingText, systemImage: "clock")
                if !distanceText.isEmpty {
                    Label(distanceText, systemImage: "location")
                }
                Spacer()
                Text("\(rally.maxParticipants - 5)/\(rally.maxParticipants)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            ProgressView(value: 0.4)
                .tint(.orange)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
