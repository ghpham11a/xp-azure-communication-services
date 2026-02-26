package com.example.azurecommunication.features.chatsetup

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.azurecommunication.data.repository.AcsRepository
import com.example.azurecommunication.shared.state.SharedState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class ChatSetupUiState(
    val isLoading: Boolean = false,
    val error: String? = null
)

@HiltViewModel
class ChatSetupViewModel @Inject constructor(
    private val repository: AcsRepository,
    private val sharedState: SharedState
) : ViewModel() {

    private val _uiState = MutableStateFlow(ChatSetupUiState())
    val uiState: StateFlow<ChatSetupUiState> = _uiState.asStateFlow()

    fun createChatThread(topic: String = "Chat") {
        val user = sharedState.user.value ?: return

        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }

            repository.createChatThread(
                userId = user.userId,
                displayName = user.displayName,
                topic = topic
            )
                .onSuccess { threadId ->
                    sharedState.setThreadId(threadId)
                    _uiState.update { it.copy(isLoading = false) }
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
        val user = sharedState.user.value ?: return

        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }

            repository.joinChatThread(
                threadId = threadId,
                userId = user.userId,
                displayName = user.displayName
            )
                .onSuccess {
                    sharedState.setThreadId(threadId)
                    _uiState.update { it.copy(isLoading = false) }
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

    fun clearError() {
        _uiState.update { it.copy(error = null) }
    }

    fun goBack() {
        sharedState.leaveChat()
    }
}
