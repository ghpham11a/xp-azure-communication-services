import Foundation

protocol TokensRepo: Sendable {
    func createToken(displayName: String) async throws -> TokenResponse
}
