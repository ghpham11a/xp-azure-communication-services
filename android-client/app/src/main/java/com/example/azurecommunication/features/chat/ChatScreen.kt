package com.example.azurecommunication.features.chat

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.widget.Toast
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import com.azure.android.communication.common.CommunicationTokenCredential
import com.azure.android.communication.common.CommunicationUserIdentifier
import com.azure.android.communication.ui.chat.ChatAdapterBuilder
import com.azure.android.communication.ui.chat.presentation.ChatThreadView
import com.example.azurecommunication.config.AcsConfig
import com.example.azurecommunication.data.models.AcsUser
import com.example.azurecommunication.shared.components.CopyableIdCard

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChatScreen(
    user: AcsUser,
    threadId: String,
    onLeave: () -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current

    fun copyThreadIdToClipboard() {
        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("Thread ID", threadId)
        clipboard.setPrimaryClip(clip)
        Toast.makeText(context, "Thread ID copied!", Toast.LENGTH_SHORT).show()
    }

    val chatAdapter = remember(user.token, threadId) {
        try {
            val credential = CommunicationTokenCredential(user.token)
            val identity = CommunicationUserIdentifier(user.userId)

            ChatAdapterBuilder()
                .endpoint(AcsConfig.ACS_ENDPOINT)
                .credential(credential)
                .identity(identity)
                .displayName(user.displayName)
                .threadId(threadId)
                .build()
        } catch (e: Exception) {
            null
        }
    }

    DisposableEffect(chatAdapter) {
        chatAdapter?.connect(context)
        onDispose {
            chatAdapter?.disconnect()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Chat")
                        Text(
                            text = "Thread: ${threadId.take(8)}...",
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
                    IconButton(onClick = { copyThreadIdToClipboard() }) {
                        Icon(Icons.Default.Share, contentDescription = "Copy Thread ID")
                    }
                }
            )
        },
        modifier = modifier
    ) { padding ->
        Surface(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            if (chatAdapter != null) {
                AndroidView(
                    factory = { ctx ->
                        ChatThreadView(ctx, chatAdapter)
                    },
                    modifier = Modifier.fillMaxSize()
                )
            } else {
                Column(
                    modifier = Modifier.fillMaxSize(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Text("Failed to initialize chat")

                    Spacer(modifier = Modifier.height(16.dp))

                    CopyableIdCard(
                        label = "Thread ID",
                        value = threadId
                    )
                }
            }
        }
    }
}
