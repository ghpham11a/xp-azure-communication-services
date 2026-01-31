//
//  AcsRepository.swift
//  AzureCommunication
//

import Foundation

actor AcsRepository {
    static let shared = AcsRepository()

    private let apiService = AcsApiService.shared

    private init() {}

    func getAcsToken(displayName: String) async throws -> AcsUser {
        let response = try await apiService.createToken(displayName: displayName)
        return AcsUser(
            userId: response.userId,
            token: response.token,
            displayName: displayName
        )
    }

    func createChatThread(userId: String, displayName: String, topic: String) async throws -> String {
        let response = try await apiService.createChatThread(
            userId: userId,
            displayName: displayName,
            topic: topic
        )
        return response.threadId
    }

    func joinChatThread(threadId: String, userId: String, displayName: String) async throws {
        _ = try await apiService.joinChatThread(
            threadId: threadId,
            userId: userId,
            displayName: displayName
        )
    }
}
