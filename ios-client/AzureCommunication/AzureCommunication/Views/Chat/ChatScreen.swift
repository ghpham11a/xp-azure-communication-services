//
//  ChatScreen.swift
//  AzureCommunication
//

import SwiftUI
import AzureCommunicationChat
import AzureCommunicationCommon
internal import AzureCore

struct ChatScreen: View {
    @ObservedObject var viewModel: AcsViewModel
    @State private var messageText = ""
    @State private var messages: [ChatMessageItem] = []
    @State private var chatClient: ChatClient?
    @State private var chatThreadClient: ChatThreadClient?
    @State private var isInitializing = true
    @State private var initError: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isInitializing {
                    Spacer()
                    ProgressView("Connecting to chat...")
                    Spacer()
                } else if let error = initError {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Failed to connect")
                            .font(.headline)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        if let threadId = viewModel.threadId {
                            ThreadIdCard(threadId: threadId)
                        }
                    }
                    .padding()
                    Spacer()
                } else {
                    // Messages list
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 12) {
                                ForEach(messages) { message in
                                    MessageBubble(
                                        message: message,
                                        isCurrentUser: message.senderId == viewModel.user?.userId
                                    )
                                }
                            }
                            .padding()
                        }
                        .onChange(of: messages.count) { _, _ in
                            if let lastMessage = messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }

                    Divider()

                    // Message input
                    HStack(spacing: 12) {
                        TextField("Type a message...", text: $messageText)
                            .textFieldStyle(.roundedBorder)

                        Button(action: sendMessage) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                        }
                        .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: viewModel.leaveChat) {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let threadId = viewModel.threadId {
                        Button(action: { copyToClipboard(threadId) }) {
                            Image(systemName: "doc.on.doc")
                        }
                    }
                }
            }
            .task {
                await initializeChat()
            }
        }
    }

    private func initializeChat() async {
        guard let user = viewModel.user,
              let threadId = viewModel.threadId else {
            initError = "Missing user or thread information"
            isInitializing = false
            return
        }

        do {
            let credential = try CommunicationTokenCredential(token: user.token)
            let options = AzureCommunicationChatClientOptions()

            chatClient = try ChatClient(
                endpoint: AcsConfig.acsEndpoint,
                credential: credential,
                withOptions: options
            )

            chatThreadClient = try chatClient?.createClient(forThread: threadId)

            // Load existing messages
            await loadMessages()

            isInitializing = false
        } catch {
            initError = error.localizedDescription
            isInitializing = false
        }
    }

    private func loadMessages() async {
        guard let threadClient = chatThreadClient else { return }

        threadClient.listMessages { result, _ in
            switch result {
            case .success(let messagesPagedCollection):
                var loadedMessages: [ChatMessageItem] = []

                messagesPagedCollection.forEachPage { messagesPage in
                    for message in messagesPage {
                        if message.type == ChatMessageType.text,
                           let content = message.content?.message {
                            let item = ChatMessageItem(
                                id: message.id,
                                content: content,
                                senderDisplayName: message.senderDisplayName ?? "Unknown",
                                senderId: (message.sender as? CommunicationUserIdentifier)?.identifier ?? "",
                                createdOn: message.createdOn.value
                            )
                            loadedMessages.append(item)
                        }
                    }
                    return true // Continue to next page
                }

                Task { @MainActor in
                    self.messages = loadedMessages.sorted { $0.createdOn < $1.createdOn }
                }

            case .failure(let error):
                print("Failed to load messages: \(error)")
            }
        }
    }

    private func sendMessage() {
        let content = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty,
              let threadClient = chatThreadClient,
              let user = viewModel.user else { return }

        let messageToSend = content
        messageText = ""

        let request = SendChatMessageRequest(
            content: messageToSend,
            senderDisplayName: user.displayName
        )

        threadClient.send(message: request) { result, _ in
            Task { @MainActor in
                switch result {
                case .success(let sendResult):
                    let newMessage = ChatMessageItem(
                        id: sendResult.id,
                        content: messageToSend,
                        senderDisplayName: user.displayName,
                        senderId: user.userId,
                        createdOn: Date()
                    )
                    self.messages.append(newMessage)
                case .failure(let error):
                    print("Failed to send message: \(error)")
                    self.messageText = messageToSend
                }
            }
        }
    }

    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
}

// MARK: - Supporting Types

struct ChatMessageItem: Identifiable {
    let id: String
    let content: String
    let senderDisplayName: String
    let senderId: String
    let createdOn: Date
}

struct MessageBubble: View {
    let message: ChatMessageItem
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                if !isCurrentUser {
                    Text(message.senderDisplayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(message.content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isCurrentUser ? Color.accentColor : Color(.secondarySystemBackground))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .cornerRadius(16)
            }

            if !isCurrentUser { Spacer() }
        }
    }
}

struct ThreadIdCard: View {
    let threadId: String

    var body: some View {
        VStack(spacing: 8) {
            Text("Thread ID")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(threadId)
                .font(.system(.caption, design: .monospaced))
                .multilineTextAlignment(.center)
            Button("Copy to Clipboard") {
                UIPasteboard.general.string = threadId
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    ChatScreen(viewModel: AcsViewModel())
}
