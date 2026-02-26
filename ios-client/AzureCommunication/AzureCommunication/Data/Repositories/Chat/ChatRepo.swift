import Foundation

protocol ChatRepo: Sendable {
    func createThread(userId: String, displayName: String, topic: String) async throws -> CreateThreadResponse
    func joinThread(threadId: String, userId: String, displayName: String) async throws -> JoinThreadResponse
}
