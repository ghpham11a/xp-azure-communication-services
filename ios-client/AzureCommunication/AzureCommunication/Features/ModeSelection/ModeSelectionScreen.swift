import SwiftUI

struct ModeSelectionScreen: View {
    @Environment(SharedState.self) private var sharedState
    @Environment(RouteManager.self) private var routeManager

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            ModeCard(
                title: "Chat",
                description: "Start or join a text chat conversation",
                systemImage: "message.fill"
            ) {
                routeManager.navigate(to: .chatSetup)
            }

            ModeCard(
                title: "Video Call",
                description: "Start or join a video call",
                systemImage: "video.fill"
            ) {
                routeManager.navigate(to: .callSetup)
            }

            Spacer()
        }
        .padding(24)
        .navigationTitle("Welcome, \(sharedState.user?.displayName ?? "User")")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { routeManager.disconnect() }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ModeSelectionScreen()
            .environment(SharedState())
            .environment(RouteManager(sharedState: SharedState()))
    }
}
