import Foundation

@Observable
class CallSetupViewModel {
    let sharedState: SharedState
    private let routeManager: RouteManager

    init(sharedState: SharedState, routeManager: RouteManager) {
        self.sharedState = sharedState
        self.routeManager = routeManager
    }

    func createGroupCall() {
        routeManager.navigate(to: .calling(groupId: UUID().uuidString))
    }

    func joinGroupCall(_ groupId: String) {
        routeManager.navigate(to: .calling(groupId: groupId))
    }

    func goBack() {
        routeManager.pop()
    }
}
