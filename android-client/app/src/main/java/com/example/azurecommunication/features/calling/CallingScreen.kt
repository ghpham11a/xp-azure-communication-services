package com.example.azurecommunication.features.calling

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.widget.Toast
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.azure.android.communication.common.CommunicationTokenCredential
import com.azure.android.communication.ui.calling.CallCompositeBuilder
import com.azure.android.communication.ui.calling.models.CallCompositeGroupCallLocator
import com.azure.android.communication.ui.calling.models.CallCompositeLocalOptions
import com.azure.android.communication.ui.calling.models.CallCompositeParticipantViewData
import com.azure.android.communication.ui.calling.models.CallCompositeRemoteOptions
import com.example.azurecommunication.data.models.AcsUser
import com.example.azurecommunication.shared.components.CopyableIdCard
import java.util.UUID

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CallingScreen(
    user: AcsUser,
    groupId: String,
    onLeave: () -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current

    fun copyGroupIdToClipboard() {
        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("Group ID", groupId)
        clipboard.setPrimaryClip(clip)
        Toast.makeText(context, "Group ID copied!", Toast.LENGTH_SHORT).show()
    }

    val credential = remember(user.token) {
        try {
            CommunicationTokenCredential(user.token)
        } catch (e: Exception) {
            null
        }
    }

    val callComposite = remember(credential) {
        credential?.let {
            CallCompositeBuilder()
                .credential(it)
                .displayName(user.displayName)
                .build()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Video Call")
                        Text(
                            text = "Group: ${groupId.take(8)}...",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onLeave) {
                        Icon(
                            Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "Leave"
                        )
                    }
                },
                actions = {
                    IconButton(onClick = { copyGroupIdToClipboard() }) {
                        Icon(Icons.Default.Share, contentDescription = "Copy Group ID")
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
            Text(
                text = "Ready to join call",
                style = MaterialTheme.typography.headlineSmall,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(8.dp))

            CopyableIdCard(
                label = "Group ID",
                value = groupId
            )

            Spacer(modifier = Modifier.height(24.dp))

            Button(
                onClick = {
                    if (callComposite != null && credential != null) {
                        val locator = CallCompositeGroupCallLocator(UUID.fromString(groupId))
                        val remoteOptions = CallCompositeRemoteOptions(locator, credential, user.displayName)
                        val localOptions = CallCompositeLocalOptions()
                            .setParticipantViewData(
                                CallCompositeParticipantViewData().setDisplayName(user.displayName)
                            )
                        callComposite.launch(context, remoteOptions, localOptions)
                    } else {
                        Toast.makeText(context, "Failed to initialize call", Toast.LENGTH_SHORT).show()
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                enabled = callComposite != null && credential != null
            ) {
                Text("Join Call")
            }

            Spacer(modifier = Modifier.height(16.dp))

            OutlinedButton(
                onClick = onLeave,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Back")
            }

            Spacer(modifier = Modifier.height(32.dp))

            Text(
                text = "Share the Group ID with others so they can join the same call",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center
            )
        }
    }
}
