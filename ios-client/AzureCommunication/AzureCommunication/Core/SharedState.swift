import Foundation

@Observable
final class SharedState {
    var user: AcsUser?
    var isConnected = false
    var mode: CommunicationMode?
    var threadId: String?
    var groupId: String?
    var isLoading = false
    var error: String?

    func connect(user: AcsUser) {
        self.user = user
        self.isConnected = true
    }

    func disconnect() {
        user = nil
        isConnected = false
        mode = nil
        threadId = nil
        groupId = nil
        error = nil
    }

    func clearError() {
        error = nil
    }
}
