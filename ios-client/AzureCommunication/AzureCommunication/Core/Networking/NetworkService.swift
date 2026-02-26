import Foundation

final class NetworkService: Networking, @unchecked Sendable {
    private let baseURL: String
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(baseURL: String = AcsConfig.apiBaseURL) {
        self.baseURL = baseURL

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)

        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    func makeRequest<T: Decodable>(endpoint: any Endpoint) async throws -> T {
        let request = try buildRequest(endpoint: endpoint)
        let (data, response) = try await perform(request)

        try validate(response: response, data: data)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    func makeRequestNoContent(endpoint: any Endpoint) async throws {
        let request = try buildRequest(endpoint: endpoint)
        let (data, response) = try await perform(request)
        try validate(response: response, data: data)
    }

    // MARK: - Private

    private func buildRequest(endpoint: any Endpoint) throws -> URLRequest {
        guard var components = URLComponents(string: "\(baseURL)\(endpoint.path)") else {
            throw NetworkError.invalidURL
        }

        if let queryItems = endpoint.queryItems {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let headers = endpoint.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        request.httpBody = endpoint.body

        return request
    }

    private func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8)
            throw NetworkError.serverError(httpResponse.statusCode, message)
        }
    }
}
