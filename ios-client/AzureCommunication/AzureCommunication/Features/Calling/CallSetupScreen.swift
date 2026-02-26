import SwiftUI

struct CallSetupScreen: View {
    @State private var viewModel: CallSetupViewModel
    @State private var groupIdToJoin = ""

    init(viewModel: CallSetupViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Create New Call Section
                VStack(spacing: 16) {
                    Text("Start New Call")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Create a new group call and share the ID with others to join")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button(action: { viewModel.createGroupCall() }) {
                        Text("Start New Call")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

                // Divider
                HStack {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 1)
                    Text("OR")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 1)
                }

                // Join Existing Call Section
                VStack(spacing: 16) {
                    Text("Join Existing Call")
                        .font(.title2)
                        .fontWeight(.semibold)

                    TextField("Group ID", text: $groupIdToJoin)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)

                    Button(action: {
                        viewModel.joinGroupCall(groupIdToJoin)
                    }) {
                        Text("Join Call")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.clear)
                            .foregroundColor(.accentColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.accentColor, lineWidth: 1)
                            )
                    }
                    .disabled(groupIdToJoin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Spacer()
            }
            .padding(24)
        }
        .navigationTitle("Video Call Setup")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { viewModel.goBack() }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
}
