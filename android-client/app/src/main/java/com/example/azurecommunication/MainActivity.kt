package com.example.azurecommunication

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
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.azurecommunication.data.models.CommunicationMode
import com.example.azurecommunication.ui.screens.CallSetupScreen
import com.example.azurecommunication.ui.screens.CallingScreen
import com.example.azurecommunication.ui.screens.ChatScreen
import com.example.azurecommunication.ui.screens.ChatSetupScreen
import com.example.azurecommunication.ui.screens.HomeScreen
import com.example.azurecommunication.ui.screens.ModeSelectionScreen
import com.example.azurecommunication.ui.theme.AzureCommunicationTheme
import com.example.azurecommunication.ui.viewmodel.AcsViewModel

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
    viewModel: AcsViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    when {
        // Not connected - show home screen
        !uiState.isConnected -> {
            HomeScreen(
                uiState = uiState,
                onConnect = viewModel::connect,
                onClearError = viewModel::clearError,
                modifier = Modifier.fillMaxSize()
            )
        }

        // Connected but no mode selected - show mode selection
        uiState.mode == null -> {
            ModeSelectionScreen(
                uiState = uiState,
                onSelectMode = viewModel::setMode,
                onDisconnect = viewModel::disconnect,
                modifier = Modifier.fillMaxSize()
            )
        }

        // Chat mode selected
        uiState.mode == CommunicationMode.CHAT -> {
            if (uiState.threadId == null) {
                // No thread yet - show chat setup
                ChatSetupScreen(
                    uiState = uiState,
                    onCreateThread = viewModel::createChatThread,
                    onJoinThread = viewModel::joinChatThread,
                    onBack = { viewModel.setMode(CommunicationMode.CHAT).let { viewModel.leaveChat() } },
                    onClearError = viewModel::clearError,
                    modifier = Modifier.fillMaxSize()
                )
            } else {
                // Have thread - show chat
                ChatScreen(
                    uiState = uiState,
                    onLeave = viewModel::leaveChat,
                    modifier = Modifier.fillMaxSize()
                )
            }
        }

        // Video mode selected
        uiState.mode == CommunicationMode.VIDEO -> {
            if (uiState.groupId == null) {
                // No group yet - show call setup
                CallSetupScreen(
                    uiState = uiState,
                    onCreateCall = viewModel::createGroupCall,
                    onJoinCall = viewModel::joinGroupCall,
                    onBack = viewModel::leaveCall,
                    modifier = Modifier.fillMaxSize()
                )
            } else {
                // Have group - show calling screen
                CallingScreen(
                    uiState = uiState,
                    onLeave = viewModel::leaveCall,
                    modifier = Modifier.fillMaxSize()
                )
            }
        }
    }
}