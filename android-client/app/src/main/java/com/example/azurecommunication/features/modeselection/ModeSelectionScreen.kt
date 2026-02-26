package com.example.azurecommunication.features.modeselection

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ExitToApp
import androidx.compose.material.icons.filled.Call
import androidx.compose.material.icons.filled.Email
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.azurecommunication.data.models.CommunicationMode
import com.example.azurecommunication.features.modeselection.components.ModeCard

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ModeSelectionScreen(
    displayName: String,
    onSelectMode: (CommunicationMode) -> Unit,
    onDisconnect: () -> Unit,
    modifier: Modifier = Modifier
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Welcome, $displayName")
                        Text(
                            text = "Choose a communication mode",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                },
                actions = {
                    IconButton(onClick = onDisconnect) {
                        Icon(
                            Icons.AutoMirrored.Filled.ExitToApp,
                            contentDescription = "Disconnect"
                        )
                    }
                }
            )
        },
        modifier = modifier
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            ModeCard(
                title = "Chat",
                description = "Start or join a text chat conversation",
                icon = Icons.Default.Email,
                onClick = { onSelectMode(CommunicationMode.CHAT) }
            )

            Spacer(modifier = Modifier.height(16.dp))

            ModeCard(
                title = "Video Call",
                description = "Start or join a video call",
                icon = Icons.Default.Call,
                onClick = { onSelectMode(CommunicationMode.VIDEO) }
            )
        }
    }
}
