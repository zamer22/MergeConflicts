import Foundation

@MainActor
class RallyDetailViewModel: ObservableObject {
    @Published var participants: [RallyParticipant] = []
    @Published var isJoined = false
    @Published var isLoading = false
    @Published var showMockPayment = false
    @Published var paymentSuccess = false
    @Published var errorMessage: String?

    let rally: Rally

    init(rally: Rally) {
        self.rally = rally
    }

    func loadParticipants() async {
        do {
            participants = try await APIClient.shared.get("/rallies/\(rally.id)/participants")
            let uid = AuthManager.shared.currentUser?.id.uuidString
            isJoined = participants.contains { $0.userId.uuidString == uid }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func initiateJoin() {
        showMockPayment = true
    }

    func confirmMockPayment() async {
        isLoading = true
        defer { isLoading = false }
        guard let uid = AuthManager.shared.currentUser?.id.uuidString else { return }
        do {
            struct JoinBody: Encodable { let rallyId: String; let userId: String }
            let _: RallyParticipant = try await APIClient.shared.post(
                "/participants/join",
                body: JoinBody(rallyId: rally.id.uuidString, userId: uid)
            )
            showMockPayment = false
            isJoined = true
            paymentSuccess = true
            await loadParticipants()
        } catch {
            errorMessage = "No se pudo unir: \(error.localizedDescription)"
        }
    }

    var spotsLeft: Int { max(0, rally.maxParticipants - participants.count) }
    var participationProgress: Double {
        guard rally.maxParticipants > 0 else { return 0 }
        return Double(participants.count) / Double(rally.maxParticipants)
    }
}
