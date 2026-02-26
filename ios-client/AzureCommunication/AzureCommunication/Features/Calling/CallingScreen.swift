import SwiftUI
import AzureCommunicationUICalling
import AzureCommunicationCommon

struct CallingScreen: View {
    @Environment(SharedState.self) private var sharedState
    @State var viewModel: CallingViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            if let error = viewModel.initError {
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

                if let groupId = sharedState.groupId {
                    GroupIdCard(groupId: groupId)
                }

                VStack(spacing: 16) {
                    Button(action: { viewModel.launchCall() }) {
                        Text("Join Call")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: { viewModel.leaveCall() }) {
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { viewModel.leaveCall() }) {
                    Image(systemName: "chevron.left")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if let groupId = sharedState.groupId {
                    Button(action: { copyToClipboard(groupId) }) {
                        Image(systemName: "doc.on.doc")
                    }
                }
            }
        }
        .task {
            await viewModel.requestPermissions()
        }
    }

    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
}
