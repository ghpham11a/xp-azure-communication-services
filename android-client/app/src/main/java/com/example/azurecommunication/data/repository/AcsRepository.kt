package com.example.azurecommunication.data.repository

import com.example.azurecommunication.data.api.NetworkModule
import com.example.azurecommunication.data.models.AcsUser
import com.example.azurecommunication.data.models.CreateThreadRequest
import com.example.azurecommunication.data.models.JoinThreadRequest
import com.example.azurecommunication.data.models.TokenRequest

class AcsRepository {
    private val api = NetworkModule.acsApiService

    suspend fun getAcsToken(displayName: String): Result<AcsUser> {
        return try {
            val response = api.createToken(TokenRequest(displayName))
            Result.success(
                AcsUser(
                    userId = response.userId,
                    token = response.token,
                    displayName = displayName
                )
            )
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun createChatThread(
        userId: String,
        displayName: String,
        topic: String = "Chat"
    ): Result<String> {
        return try {
            val response = api.createChatThread(
                CreateThreadRequest(
                    userId = userId,
                    displayName = displayName,
                    topic = topic
                )
            )
            Result.success(response.threadId)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun joinChatThread(
        threadId: String,
        userId: String,
        displayName: String
    ): Result<Unit> {
        return try {
            api.joinChatThread(
                threadId = threadId,
                request = JoinThreadRequest(
                    userId = userId,
                    displayName = displayName
                )
            )
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
