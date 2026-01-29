//
//  HomeScreen.swift
//  AzureCommunication
//

import SwiftUI

struct HomeScreen: View {
    @ObservedObject var viewModel: AcsViewModel
    @State private var displayName = ""

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
                .disabled(viewModel.isLoading)

            Button(action: {
                let name = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
                viewModel.connect(displayName: name.isEmpty ? "Anonymous" : name)
            }) {
                HStack {
                    if viewModel.isLoading {
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
            .disabled(viewModel.isLoading)

            Spacer()
        }
        .padding(24)
        .alert("Error", isPresented: .init(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("OK") { viewModel.clearError() }
        } message: {
            Text(viewModel.error ?? "")
        }
    }
}

#Preview {
    HomeScreen(viewModel: AcsViewModel())
}
