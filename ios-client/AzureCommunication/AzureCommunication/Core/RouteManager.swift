import SwiftUI

@Observable
final class RouteManager {
    var path = NavigationPath()
    var pendingRoute: Route?

    private let sharedState: SharedState

    init(sharedState: SharedState) {
        self.sharedState = sharedState
    }

    func navigate(to route: Route) {
        guard sharedState.isConnected else {
            pendingRoute = route
            return
        }

        switch route {
        case .chatSetup:
            sharedState.mode = .chat
        case .chat(let threadId):
            sharedState.mode = .chat
            sharedState.threadId = threadId
        case .callSetup:
            sharedState.mode = .video
        case .calling(let groupId):
            sharedState.mode = .video
            sharedState.groupId = groupId
        }

        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
        sharedState.mode = nil
        sharedState.threadId = nil
        sharedState.groupId = nil
    }

    func disconnect() {
        path = NavigationPath()
        sharedState.disconnect()
    }

    func handleDeepLink(_ url: URL) {
        guard url.scheme == "azcomms" else { return }

        let host = url.host()
        let pathComponents = url.pathComponents.filter { $0 != "/" }

        let route: Route? = switch host {
        case "chat":
            if pathComponents.count >= 2, pathComponents[0] == "join" {
                .chat(threadId: pathComponents[1])
            } else {
                .chatSetup
            }
        case "call":
            if pathComponents.count >= 2, pathComponents[0] == "join" {
                .calling(groupId: pathComponents[1])
            } else {
                .callSetup
            }
        default:
            nil
        }

        if let route {
            navigate(to: route)
        }
    }

    func replayPendingRouteIfNeeded() {
        guard let route = pendingRoute else { return }
        pendingRoute = nil
        navigate(to: route)
    }
}
