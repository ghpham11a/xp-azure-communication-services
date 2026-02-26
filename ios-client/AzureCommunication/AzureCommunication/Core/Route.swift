import Foundation

enum Route: Hashable {
    case chatSetup
    case chat(threadId: String)
    case callSetup
    case calling(groupId: String)
}
