import Foundation
import AzureCommunicationChat
import AzureCommunicationCommon
internal import AzureCore

@Observable
class ChatViewModel {
    let sharedState: SharedState
    private let routeManager: RouteManager

    var messages: [ChatMessageItem] = []
    var messageText = ""
    var isInitializing = true
    var initError: String?

    private var chatClient: ChatClient?
    private var chatThreadClient: ChatThreadClient?

    init(sharedState: SharedState, routeManager: RouteManager) {
        self.sharedState = sharedState
        self.routeManager = routeManager
    }

    func initializeChat() async {
        guard let user = sharedState.user,
              let threadId = sharedState.threadId else {
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

            await loadMessages()

            isInitializing = false
        } catch {
            initError = error.localizedDescription
            isInitializing = false
        }
    }

    func loadMessages() async {
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
                    return true
                }

                Task { @MainActor in
                    self.messages = loadedMessages.sorted { $0.createdOn < $1.createdOn }
                }

            case .failure(let error):
                print("Failed to load messages: \(error)")
            }
        }
    }

    func sendMessage() {
        let content = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty,
              let threadClient = chatThreadClient,
              let user = sharedState.user else { return }

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

    func leaveChat() {
        routeManager.popToRoot()
    }
}
