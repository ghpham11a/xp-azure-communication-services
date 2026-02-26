package com.example.azurecommunication.app

import android.Manifest
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import com.example.azurecommunication.data.models.CommunicationMode
import com.example.azurecommunication.features.callsetup.CallSetupScreen
import com.example.azurecommunication.features.calling.CallingScreen
import com.example.azurecommunication.features.chat.ChatScreen
import com.example.azurecommunication.features.chatsetup.ChatSetupScreen
import com.example.azurecommunication.features.home.HomeScreen
import com.example.azurecommunication.features.modeselection.ModeSelectionScreen
import com.example.azurecommunication.shared.theme.AzureCommunicationTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    private val requestPermissionsLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        // Handle permission results if needed
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Request permissions for camera and microphone
        requestPermissionsLauncher.launch(
            arrayOf(
                Manifest.permission.CAMERA,
                Manifest.permission.RECORD_AUDIO
            )
        )

        enableEdgeToEdge()
        setContent {
            AzureCommunicationTheme {
                AzureCommunicationApp()
            }
        }
    }
}

@Composable
fun AzureCommunicationApp(
    viewModel: MainViewModel = hiltViewModel()
) {
    val user by viewModel.user.collectAsState()
    val isConnected by viewModel.isConnected.collectAsState()
    val mode by viewModel.mode.collectAsState()
    val threadId by viewModel.threadId.collectAsState()
    val groupId by viewModel.groupId.collectAsState()

    when {
        // Not connected - show home screen
        !isConnected -> {
            HomeScreen(
                modifier = Modifier.fillMaxSize()
            )
        }

        // Connected but no mode selected - show mode selection
        mode == null -> {
            ModeSelectionScreen(
                displayName = user?.displayName ?: "User",
                onSelectMode = viewModel::setMode,
                onDisconnect = viewModel::disconnect,
                modifier = Modifier.fillMaxSize()
            )
        }

        // Chat mode selected
        mode == CommunicationMode.CHAT -> {
            val currentUser = user
            val currentThreadId = threadId

            if (currentThreadId == null) {
                // No thread yet - show chat setup
                ChatSetupScreen(
                    modifier = Modifier.fillMaxSize()
                )
            } else if (currentUser != null) {
                // Have thread - show chat
                ChatScreen(
                    user = currentUser,
                    threadId = currentThreadId,
                    onLeave = viewModel::leaveChat,
                    modifier = Modifier.fillMaxSize()
                )
            }
        }

        // Video mode selected
        mode == CommunicationMode.VIDEO -> {
            val currentUser = user
            val currentGroupId = groupId

            if (currentGroupId == null) {
                // No group yet - show call setup
                CallSetupScreen(
                    modifier = Modifier.fillMaxSize()
                )
            } else if (currentUser != null) {
                // Have group - show calling screen
                CallingScreen(
                    user = currentUser,
                    groupId = currentGroupId,
                    onLeave = viewModel::leaveCall,
                    modifier = Modifier.fillMaxSize()
                )
            }
        }
    }
}
