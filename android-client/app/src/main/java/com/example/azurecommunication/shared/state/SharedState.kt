package com.example.azurecommunication.shared.state

import com.example.azurecommunication.data.models.AcsUser
import com.example.azurecommunication.data.models.CommunicationMode
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class SharedState @Inject constructor() {

    private val _user = MutableStateFlow<AcsUser?>(null)
    val user: StateFlow<AcsUser?> = _user.asStateFlow()

    private val _isConnected = MutableStateFlow(false)
    val isConnected: StateFlow<Boolean> = _isConnected.asStateFlow()

    private val _mode = MutableStateFlow<CommunicationMode?>(null)
    val mode: StateFlow<CommunicationMode?> = _mode.asStateFlow()

    private val _threadId = MutableStateFlow<String?>(null)
    val threadId: StateFlow<String?> = _threadId.asStateFlow()

    private val _groupId = MutableStateFlow<String?>(null)
    val groupId: StateFlow<String?> = _groupId.asStateFlow()

    fun setUser(user: AcsUser?) {
        _user.value = user
        _isConnected.value = user != null
    }

    fun setMode(mode: CommunicationMode?) {
        _mode.value = mode
    }

    fun setThreadId(threadId: String?) {
        _threadId.value = threadId
    }

    fun setGroupId(groupId: String?) {
        _groupId.value = groupId
    }

    fun disconnect() {
        _user.value = null
        _isConnected.value = false
        _mode.value = null
        _threadId.value = null
        _groupId.value = null
    }

    fun leaveChat() {
        _threadId.value = null
        _mode.value = null
    }

    fun leaveCall() {
        _groupId.value = null
        _mode.value = null
    }
}
