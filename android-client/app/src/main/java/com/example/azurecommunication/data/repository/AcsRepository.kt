package com.example.azurecommunication.data.repository

import com.example.azurecommunication.data.api.AcsApiService
import com.example.azurecommunication.data.models.AcsUser
import com.example.azurecommunication.data.models.CreateThreadRequest
import com.example.azurecommunication.data.models.JoinThreadRequest
import com.example.azurecommunication.data.models.TokenRequest
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AcsRepository @Inject constructor(
    private val api: AcsApiService
) {
    suspend fun getAcsToken(displayName: String): Result<AcsUser> {
        return runCatching {
            val response = api.createToken(TokenRequest(displayName))
            AcsUser(
                userId = response.userId,
                token = response.token,
                displayName = displayName
            )
        }
    }

    suspend fun createChatThread(
        userId: String,
        displayName: String,
        topic: String = "Chat"
    ): Result<String> {
        return runCatching {
            val response = api.createChatThread(
                CreateThreadRequest(
                    userId = userId,
                    displayName = displayName,
                    topic = topic
                )
            )
            response.threadId
        }
    }

    suspend fun joinChatThread(
        threadId: String,
        userId: String,
        displayName: String
    ): Result<Unit> {
        return runCatching {
            api.joinChatThread(
                threadId = threadId,
                request = JoinThreadRequest(
                    userId = userId,
                    displayName = displayName
                )
            )
            Unit
        }
    }
}
