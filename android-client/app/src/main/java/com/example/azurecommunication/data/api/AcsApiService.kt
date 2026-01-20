package com.example.azurecommunication.data.api

import com.example.azurecommunication.data.models.CreateThreadRequest
import com.example.azurecommunication.data.models.CreateThreadResponse
import com.example.azurecommunication.data.models.JoinThreadRequest
import com.example.azurecommunication.data.models.JoinThreadResponse
import com.example.azurecommunication.data.models.TokenRequest
import com.example.azurecommunication.data.models.TokenResponse
import retrofit2.http.Body
import retrofit2.http.POST
import retrofit2.http.Path

interface AcsApiService {

    @POST("tokens/create")
    suspend fun createToken(@Body request: TokenRequest): TokenResponse

    @POST("chat/thread")
    suspend fun createChatThread(@Body request: CreateThreadRequest): CreateThreadResponse

    @POST("chat/thread/{threadId}/join")
    suspend fun joinChatThread(
        @Path("threadId") threadId: String,
        @Body request: JoinThreadRequest
    ): JoinThreadResponse
}
