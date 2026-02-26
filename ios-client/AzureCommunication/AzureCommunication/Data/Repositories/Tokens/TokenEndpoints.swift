import Foundation

enum TokenEndpoints {
    struct Create: Endpoint {
        let path = "/tokens/create"
        let method = HTTPMethod.post
        let body: Data?

        init(displayName: String) throws {
            self.body = try JSONEncoder().encode(TokenRequest(displayName: displayName))
        }
    }
}
