import SwiftUI

struct HomeScreen: View {
    @State private var viewModel: HomeViewModel
    @State private var displayName = ""

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Azure Communication Services")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Chat & Video Calling")
                .font(.headline)
                .foregroundColor(.secondary)

            Spacer()
                .frame(height: 24)

            TextField("Display Name", text: $displayName)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.words)
                .disabled(viewModel.sharedState.isLoading)

            Button(action: {
                let name = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
                viewModel.connect(displayName: name.isEmpty ? "Anonymous" : name)
            }) {
                HStack {
                    if viewModel.sharedState.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Connect")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(viewModel.sharedState.isLoading)

            Spacer()
        }
        .padding(24)
        .alert("Error", isPresented: .init(
            get: { viewModel.sharedState.error != nil },
            set: { if !$0 { viewModel.sharedState.clearError() } }
        )) {
            Button("OK") { viewModel.sharedState.clearError() }
        } message: {
            Text(viewModel.sharedState.error ?? "")
        }
    }
}
