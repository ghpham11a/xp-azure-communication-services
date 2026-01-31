//
//  AcsModels.swift
//  AzureCommunication
//

import Foundation

// MARK: - API Request/Response Models

struct TokenRequest: Codable {
    let displayName: String
}

struct TokenResponse: Codable {
    let userId: String
    let token: String
    let expiresOn: String
}

struct CreateThreadRequest: Codable {
    let userId: String
    let displayName: String
    let topic: String
}

struct CreateThreadResponse: Codable {
    let threadId: String
    let topic: String
}

struct JoinThreadRequest: Codable {
    let userId: String
    let displayName: String
}

struct JoinThreadResponse: Codable {
    let success: Bool
    let threadId: String
    let userId: String
}

// MARK: - App Models

struct AcsUser: Equatable {
    let userId: String
    let token: String
    let displayName: String
}

enum CommunicationMode: String, CaseIterable {
    case chat
    case video
}
