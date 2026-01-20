package com.example.azurecommunication.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.azurecommunication.data.models.AcsUser
import com.example.azurecommunication.data.models.CommunicationMode
import com.example.azurecommunication.data.repository.AcsRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.util.UUID

data class AcsUiState(
    val isLoading: Boolean = false,
    val error: String? = null,
    val user: AcsUser? = null,
    val isConnected: Boolean = false,
    val mode: CommunicationMode? = null,
    val threadId: String? = null,
    val groupId: String? = null
)

class AcsViewModel : ViewModel() {
    private val repository = AcsRepository()

    private val _uiState = MutableStateFlow(AcsUiState())
    val uiState: StateFlow<AcsUiState> = _uiState.asStateFlow()

    fun connect(displayName: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }

            repository.getAcsToken(displayName)
                .onSuccess { user ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            user = user,
                            isConnected = true
                        )
                    }
                }
                .onFailure { e ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            error = e.message ?: "Failed to connect"
                        )
                    }
                }
        }
    }

    fun setMode(mode: CommunicationMode) {
        _uiState.update { it.copy(mode = mode) }
    }

    fun createChatThread(topic: String = "Chat") {
        val user = _uiState.value.user ?: return

        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }

            repository.createChatThread(
                userId = user.userId,
                displayName = user.displayName,
                topic = topic
            )
                .onSuccess { threadId ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            threadId = threadId
                        )
                    }
                }
                .onFailure { e ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            error = e.message ?: "Failed to create chat thread"
                        )
                    }
                }
        }
    }

    fun joinChatThread(threadId: String) {
        val user = _uiState.value.user ?: return

        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }

            repository.joinChatThread(
                threadId = threadId,
                userId = user.userId,
                displayName = user.displayName
            )
                .onSuccess {
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            threadId = threadId
                        )
                    }
                }
                .onFailure { e ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            error = e.message ?: "Failed to join chat thread"
                        )
                    }
                }
        }
    }

    fun setThreadId(threadId: String) {
        _uiState.update { it.copy(threadId = threadId) }
    }

    fun createGroupCall() {
        val groupId = UUID.randomUUID().toString()
        _uiState.update { it.copy(groupId = groupId) }
    }

    fun joinGroupCall(groupId: String) {
        _uiState.update { it.copy(groupId = groupId) }
    }

    fun clearError() {
        _uiState.update { it.copy(error = null) }
    }

    fun disconnect() {
        _uiState.update { AcsUiState() }
    }

    fun leaveChat() {
        _uiState.update { it.copy(threadId = null, mode = null) }
    }

    fun leaveCall() {
        _uiState.update { it.copy(groupId = null, mode = null) }
    }
}
