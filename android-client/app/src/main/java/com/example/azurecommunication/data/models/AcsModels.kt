package com.example.azurecommunication.data.models

import com.squareup.moshi.JsonClass

@JsonClass(generateAdapter = true)
data class TokenRequest(
    val displayName: String = "Anonymous"
)

@JsonClass(generateAdapter = true)
data class TokenResponse(
    val userId: String,
    val token: String,
    val expiresOn: String
)

@JsonClass(generateAdapter = true)
data class CreateThreadRequest(
    val userId: String,
    val displayName: String,
    val topic: String = "Chat"
)

@JsonClass(generateAdapter = true)
data class CreateThreadResponse(
    val threadId: String,
    val topic: String
)

@JsonClass(generateAdapter = true)
data class JoinThreadRequest(
    val userId: String,
    val displayName: String
)

@JsonClass(generateAdapter = true)
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
