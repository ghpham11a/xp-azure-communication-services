//
//  CallingScreen.swift
//  AzureCommunication
//

import SwiftUI
import AzureCommunicationUICalling
import AzureCommunicationCommon

struct CallingScreen: View {
    @ObservedObject var viewModel: AcsViewModel
    @State private var callComposite: CallComposite?
    @State private var isCallActive = false
    @State private var initError: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                if let error = initError {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Error")
                            .font(.headline)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    Text("Ready to join call")
                        .font(.title2)
                        .fontWeight(.semibold)

                    if let groupId = viewModel.groupId {
                        GroupIdCard(groupId: groupId)
                    }

                    VStack(spacing: 16) {
                        Button(action: launchCall) {
                            Text("Join Call")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: viewModel.leaveCall) {
                            Text("Back")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.clear)
                                .foregroundColor(.accentColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.accentColor, lineWidth: 1)
                                )
                        }
                    }

                    Text("Share the Group ID with others so they can join the same call")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding(24)
            .navigationTitle("Video Call")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: viewModel.leaveCall) {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let groupId = viewModel.groupId {
                        Button(action: { copyToClipboard(groupId) }) {
                            Image(systemName: "doc.on.doc")
                        }
                    }
                }
            }
            .task {
                await requestPermissions()
            }
        }
    }

    private func requestPermissions() async {
        let permissions = await PermissionManager.shared.requestAllPermissions()
        if !permissions.camera || !permissions.microphone {
            initError = "Camera and microphone permissions are required for video calls"
        }
    }

    private func launchCall() {
        guard let user = viewModel.user,
              let groupIdString = viewModel.groupId,
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

    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
}

struct GroupIdCard: View {
    let groupId: String

    var body: some View {
        Button(action: { UIPasteboard.general.string = groupId }) {
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Group ID")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(groupId)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.accentColor)
                }
                Text("Tap to copy")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CallingScreen(viewModel: AcsViewModel())
}
