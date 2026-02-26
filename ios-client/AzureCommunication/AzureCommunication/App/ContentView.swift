import SwiftUI

struct ContentView: View {
    @Environment(SharedState.self) private var sharedState
    @Environment(RouteManager.self) private var routeManager

    var body: some View {
        @Bindable var routeManager = routeManager

        if !sharedState.isConnected {
            HomeScreen(viewModel: DependencyContainer.shared.resolve(HomeViewModel.self))
                .onChange(of: sharedState.isConnected) { _, isConnected in
                    if isConnected {
                        routeManager.replayPendingRouteIfNeeded()
                    }
                }
        } else {
            NavigationStack(path: $routeManager.path) {
                ModeSelectionScreen()
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .chatSetup:
                            ChatSetupScreen(viewModel: DependencyContainer.shared.resolve(ChatSetupViewModel.self))
                        case .chat:
                            ChatScreen(viewModel: DependencyContainer.shared.resolve(ChatViewModel.self))
                        case .callSetup:
                            CallSetupScreen(viewModel: DependencyContainer.shared.resolve(CallSetupViewModel.self))
                        case .calling:
                            CallingScreen(viewModel: DependencyContainer.shared.resolve(CallingViewModel.self))
                        }
                    }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(SharedState())
        .environment(RouteManager(sharedState: SharedState()))
}
