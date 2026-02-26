package com.example.azurecommunication.features.callsetup

import androidx.lifecycle.ViewModel
import com.example.azurecommunication.shared.state.SharedState
import dagger.hilt.android.lifecycle.HiltViewModel
import java.util.UUID
import javax.inject.Inject

@HiltViewModel
class CallSetupViewModel @Inject constructor(
    private val sharedState: SharedState
) : ViewModel() {

    fun createGroupCall() {
        val groupId = UUID.randomUUID().toString()
        sharedState.setGroupId(groupId)
    }

    fun joinGroupCall(groupId: String) {
        sharedState.setGroupId(groupId)
    }

    fun goBack() {
        sharedState.leaveCall()
    }
}
