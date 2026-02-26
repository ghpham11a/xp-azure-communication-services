import Foundation
import AzureCommunicationUICalling
import AzureCommunicationCommon

@Observable
class CallingViewModel {
    let sharedState: SharedState
    private let routeManager: RouteManager

    var callComposite: CallComposite?
    var isCallActive = false
    var initError: String?

    init(sharedState: SharedState, routeManager: RouteManager) {
        self.sharedState = sharedState
        self.routeManager = routeManager
    }

    func requestPermissions() async {
        let permissions = await PermissionManager.shared.requestAllPermissions()
        if !permissions.camera || !permissions.microphone {
            initError = "Camera and microphone permissions are required for video calls"
        }
    }

    func launchCall() {
        guard let user = sharedState.user,
              let groupIdString = sharedState.groupId,
              let groupId = UUID(uuidString: groupIdString) else {
            initError = "Invalid group ID or user information"
            return
        }

        do {
            let credential = try CommunicationTokenCredential(token: user.token)

            let callCompositeOptions = CallCompositeOptions()
            callComposite = CallComposite(withOptions: callCompositeOptions)

            let communicationIdentifier = CommunicationUserIdentifier(user.userId)
            let localOptions = LocalOptions(participantViewData: ParticipantViewData(displayName: user.displayName))

            let remoteOptions = RemoteOptions(
                for: .groupCall(groupId: groupId),
                credential: credential,
                displayName: user.displayName
            )

            callComposite?.launch(remoteOptions: remoteOptions, localOptions: localOptions)

        } catch {
            initError = error.localizedDescription
        }
    }

    func leaveCall() {
        routeManager.popToRoot()
    }
}
