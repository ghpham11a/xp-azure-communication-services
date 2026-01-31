//
//  ModeSelectionScreen.swift
//  AzureCommunication
//

import SwiftUI

struct ModeSelectionScreen: View {
    @ObservedObject var viewModel: AcsViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()

                ModeCard(
                    title: "Chat",
                    description: "Start or join a text chat conversation",
                    systemImage: "message.fill"
                ) {
                    viewModel.setMode(.chat)
                }

                ModeCard(
                    title: "Video Call",
                    description: "Start or join a video call",
                    systemImage: "video.fill"
                ) {
                    viewModel.setMode(.video)
                }

                Spacer()
            }
            .padding(24)
            .navigationTitle("Welcome, \(viewModel.user?.displayName ?? "User")")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.disconnect) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
        }
    }
}

struct ModeCard: View {
    let title: String
    let description: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundColor(.accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
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
    let viewModel = AcsViewModel()
    return ModeSelectionScreen(viewModel: viewModel)
}
