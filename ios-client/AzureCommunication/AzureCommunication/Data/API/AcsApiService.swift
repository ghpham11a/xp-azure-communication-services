//
//  AcsApiService.swift
//  AzureCommunication
//

import Foundation

enum AcsApiError: LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case serverError(Int, String?)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return message ?? "Server error: \(code)"
        }
    }
}

actor AcsApiService {
    static let shared = AcsApiService()

    private let baseURL: String
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private init() {
        self.baseURL = AcsConfig.apiBaseURL

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)

        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    // MARK: - API Methods

    func createToken(displayName: String) async throws -> TokenResponse {
        let request = TokenRequest(displayName: displayName)
        return try await post(endpoint: "/tokens/create", body: request)
    }

    func createChatThread(userId: String, displayName: String, topic: String) async throws -> CreateThreadResponse {
        let request = CreateThreadRequest(userId: userId, displayName: displayName, topic: topic)
        return try await post(endpoint: "/chat/thread", body: request)
    }

    func joinChatThread(threadId: String, userId: String, displayName: String) async throws -> JoinThreadResponse {
        let request = JoinThreadRequest(userId: userId, displayName: displayName)
        return try await post(endpoint: "/chat/thread/\(threadId)/join", body: request)
    }

    // MARK: - Private Helpers

    private func post<T: Encodable, R: Decodable>(endpoint: String, body: T) async throws -> R {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw AcsApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            throw AcsApiError.requestFailed(error)
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw AcsApiError.requestFailed(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AcsApiError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8)
            throw AcsApiError.serverError(httpResponse.statusCode, message)
        }

        do {
            return try decoder.decode(R.self, from: data)
        } catch {
            throw AcsApiError.decodingFailed(error)
        }
    }
}
