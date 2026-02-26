package com.example.azurecommunication.app

import androidx.lifecycle.ViewModel
import com.example.azurecommunication.data.models.AcsUser
import com.example.azurecommunication.data.models.CommunicationMode
import com.example.azurecommunication.shared.state.SharedState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.StateFlow
import javax.inject.Inject

@HiltViewModel
class MainViewModel @Inject constructor(
    private val sharedState: SharedState
) : ViewModel() {

    val user: StateFlow<AcsUser?> = sharedState.user
    val isConnected: StateFlow<Boolean> = sharedState.isConnected
    val mode: StateFlow<CommunicationMode?> = sharedState.mode
    val threadId: StateFlow<String?> = sharedState.threadId
    val groupId: StateFlow<String?> = sharedState.groupId

    fun setMode(mode: CommunicationMode) {
        sharedState.setMode(mode)
    }

    fun disconnect() {
        sharedState.disconnect()
    }

    fun leaveChat() {
        sharedState.leaveChat()
    }

    fun leaveCall() {
        sharedState.leaveCall()
    }
}
