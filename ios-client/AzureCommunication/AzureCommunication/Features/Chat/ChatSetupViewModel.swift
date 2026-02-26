import Foundation

@Observable
class ChatSetupViewModel {
    let sharedState: SharedState
    private let chatRepo: ChatRepo
    private let routeManager: RouteManager

    init(sharedState: SharedState, chatRepo: ChatRepo, routeManager: RouteManager) {
        self.sharedState = sharedState
        self.chatRepo = chatRepo
        self.routeManager = routeManager
    }

    func createThread(topic: String = "Chat") {
        guard let user = sharedState.user else { return }

        Task { @MainActor in
            sharedState.isLoading = true
            sharedState.error = nil

            do {
                let response = try await chatRepo.createThread(
                    userId: user.userId,
                    displayName: user.displayName,
                    topic: topic
                )
                routeManager.navigate(to: .chat(threadId: response.threadId))
            } catch {
                sharedState.error = error.localizedDescription
            }

            sharedState.isLoading = false
        }
    }

    func joinThread(_ threadId: String) {
        guard let user = sharedState.user else { return }

        Task { @MainActor in
            sharedState.isLoading = true
            sharedState.error = nil

            do {
                _ = try await chatRepo.joinThread(
                    threadId: threadId,
                    userId: user.userId,
                    displayName: user.displayName
                )
                routeManager.navigate(to: .chat(threadId: threadId))
            } catch {
                sharedState.error = error.localizedDescription
            }

            sharedState.isLoading = false
        }
    }

    func goBack() {
        routeManager.pop()
    }
}
