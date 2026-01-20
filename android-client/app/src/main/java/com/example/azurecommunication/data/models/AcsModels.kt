package com.example.azurecommunication.data.models

import kotlinx.serialization.Serializable

@Serializable
data class TokenRequest(
    val displayName: String = "Anonymous"
)

@Serializable
data class TokenResponse(
    val userId: String,
    val token: String,
    val expiresOn: String
)

@Serializable
data class CreateThreadRequest(
    val userId: String,
    val displayName: String,
    val topic: String = "Chat"
)

@Serializable
data class CreateThreadResponse(
    val threadId: String,
    val topic: String
)

@Serializable
data class JoinThreadRequest(
    val userId: String,
    val displayName: String
)

@Serializable
data class JoinThreadResponse(
    val success: Boolean,
    val threadId: String,
    val userId: String
)

data class AcsUser(
    val userId: String,
    val token: String,
    val displayName: String
)

enum class CommunicationMode {
    CHAT,
    VIDEO
}
