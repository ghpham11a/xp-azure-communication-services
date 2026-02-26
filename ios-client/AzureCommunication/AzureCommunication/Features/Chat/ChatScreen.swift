import SwiftUI
import AzureCommunicationChat
import AzureCommunicationCommon
internal import AzureCore

struct ChatScreen: View {
    @Environment(SharedState.self) private var sharedState
    @State var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isInitializing {
                Spacer()
                ProgressView("Connecting to chat...")
                Spacer()
            } else if let error = viewModel.initError {
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

                    if let threadId = sharedState.threadId {
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
                            ForEach(viewModel.messages) { message in
                                MessageBubble(
                                    message: message,
                                    isCurrentUser: message.senderId == sharedState.user?.userId
                                )
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                Divider()

                // Message input
                HStack(spacing: 12) {
                    @Bindable var viewModel = viewModel
                    TextField("Type a message...", text: $viewModel.messageText)
                        .textFieldStyle(.roundedBorder)

                    Button(action: { self.viewModel.sendMessage() }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.accentColor)
                            .clipShape(Circle())
                    }
                    .disabled(self.viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(Color(.systemBackground))
            }
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { viewModel.leaveChat() }) {
                    Image(systemName: "chevron.left")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if let threadId = sharedState.threadId {
                    Button(action: { copyToClipboard(threadId) }) {
                        Image(systemName: "doc.on.doc")
                    }
                }
            }
        }
        .task {
            await viewModel.initializeChat()
        }
    }

    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
}
