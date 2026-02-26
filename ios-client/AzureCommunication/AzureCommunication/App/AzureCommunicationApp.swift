import SwiftUI

@main
struct AzureCommunicationApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(DependencyContainer.shared.resolve(SharedState.self))
                .environment(DependencyContainer.shared.resolve(RouteManager.self))
                .onOpenURL { url in
                    DependencyContainer.shared.resolve(RouteManager.self).handleDeepLink(url)
                }
        }
    }
}
