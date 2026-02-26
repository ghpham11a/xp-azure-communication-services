import Foundation

final class ChatRepository: ChatRepo, @unchecked Sendable {
    private let networking: Networking

    init(networking: Networking) {
        self.networking = networking
    }

    func createThread(userId: String, displayName: String, topic: String) async throws -> CreateThreadResponse {
        try await networking.makeRequest(
            endpoint: ChatEndpoints.CreateThread(userId: userId, displayName: displayName, topic: topic)
        )
    }

    func joinThread(threadId: String, userId: String, displayName: String) async throws -> JoinThreadResponse {
        try await networking.makeRequest(
            endpoint: ChatEndpoints.JoinThread(threadId: threadId, userId: userId, displayName: displayName)
        )
    }
}
