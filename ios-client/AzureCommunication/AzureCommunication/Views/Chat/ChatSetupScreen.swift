//
//  ChatSetupScreen.swift
//  AzureCommunication
//

import SwiftUI

struct ChatSetupScreen: View {
    @ObservedObject var viewModel: AcsViewModel
    @State private var topic = ""
    @State private var threadIdToJoin = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Create New Chat Section
                    VStack(spacing: 16) {
                        Text("Create New Chat")
                            .font(.title2)
                            .fontWeight(.semibold)

                        TextField("Chat Topic (optional)", text: $topic)
                            .textFieldStyle(.roundedBorder)
                            .disabled(viewModel.isLoading)

                        Button(action: {
                            let chatTopic = topic.trimmingCharacters(in: .whitespacesAndNewlines)
                            viewModel.createChatThread(topic: chatTopic.isEmpty ? "Chat" : chatTopic)
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Create New Chat")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(viewModel.isLoading)
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

                    // Join Existing Chat Section
                    VStack(spacing: 16) {
                        Text("Join Existing Chat")
                            .font(.title2)
                            .fontWeight(.semibold)

                        TextField("Thread ID", text: $threadIdToJoin)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .disabled(viewModel.isLoading)

                        Button(action: {
                            viewModel.joinChatThread(threadIdToJoin)
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                } else {
                                    Text("Join Chat")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.clear)
                            .foregroundColor(.accentColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.accentColor, lineWidth: 1)
                            )
                        }
                        .disabled(viewModel.isLoading || threadIdToJoin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }

                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("Chat Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: viewModel.leaveChat) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
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
}

#Preview {
    ChatSetupScreen(viewModel: AcsViewModel())
}
