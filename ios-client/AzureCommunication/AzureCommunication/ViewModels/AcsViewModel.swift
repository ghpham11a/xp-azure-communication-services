//
//  AcsViewModel.swift
//  AzureCommunication
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AcsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    @Published var user: AcsUser?
    @Published var isConnected = false
    @Published var mode: CommunicationMode?
    @Published var threadId: String?
    @Published var groupId: String?

    private let repository = AcsRepository.shared

    // MARK: - Connection

    func connect(displayName: String) {
        Task {
            isLoading = true
            error = nil

            do {
                let acsUser = try await repository.getAcsToken(displayName: displayName)
                user = acsUser
                isConnected = true
            } catch {
                self.error = error.localizedDescription
            }

            isLoading = false
        }
    }

    func disconnect() {
        user = nil
        isConnected = false
        mode = nil
        threadId = nil
        groupId = nil
        error = nil
    }

    // MARK: - Mode Selection

    func setMode(_ mode: CommunicationMode) {
        self.mode = mode
    }

    // MARK: - Chat

    func createChatThread(topic: String = "Chat") {
        guard let user = user else { return }

        Task {
            isLoading = true
            error = nil

            do {
                let newThreadId = try await repository.createChatThread(
                    userId: user.userId,
                    displayName: user.displayName,
                    topic: topic
                )
                threadId = newThreadId
            } catch {
                self.error = error.localizedDescription
            }

            isLoading = false
        }
    }

    func joinChatThread(_ threadIdToJoin: String) {
        guard let user = user else { return }

        Task {
            isLoading = true
            error = nil

            do {
                try await repository.joinChatThread(
                    threadId: threadIdToJoin,
                    userId: user.userId,
                    displayName: user.displayName
                )
                threadId = threadIdToJoin
            } catch {
                self.error = error.localizedDescription
            }

            isLoading = false
        }
    }

    func leaveChat() {
        threadId = nil
        mode = nil
    }

    // MARK: - Video Calling

    func createGroupCall() {
        groupId = UUID().uuidString
    }

    func joinGroupCall(_ groupIdToJoin: String) {
        groupId = groupIdToJoin
    }

    func leaveCall() {
        groupId = nil
        mode = nil
    }

    // MARK: - Error Handling

    func clearError() {
        error = nil
    }
}
