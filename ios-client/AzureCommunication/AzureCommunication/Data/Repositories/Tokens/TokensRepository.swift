import Foundation

final class TokensRepository: TokensRepo, @unchecked Sendable {
    private let networking: Networking

    init(networking: Networking) {
        self.networking = networking
    }

    func createToken(displayName: String) async throws -> TokenResponse {
        try await networking.makeRequest(endpoint: TokenEndpoints.Create(displayName: displayName))
    }
}
