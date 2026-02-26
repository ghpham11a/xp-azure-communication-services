import Foundation

protocol Networking: Sendable {
    func makeRequest<T: Decodable>(endpoint: any Endpoint) async throws -> T
    func makeRequestNoContent(endpoint: any Endpoint) async throws
}
