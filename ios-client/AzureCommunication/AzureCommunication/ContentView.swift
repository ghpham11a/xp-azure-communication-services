//
//  ContentView.swift
//  AzureCommunication
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AcsViewModel()

    var body: some View {
        Group {
            if !viewModel.isConnected {
                // Not connected - show home screen
                HomeScreen(viewModel: viewModel)
            } else if viewModel.mode == nil {
                // Connected but no mode selected - show mode selection
                ModeSelectionScreen(viewModel: viewModel)
            } else if viewModel.mode == .chat {
                // Chat mode
                if viewModel.threadId == nil {
                    ChatSetupScreen(viewModel: viewModel)
                } else {
                    ChatScreen(viewModel: viewModel)
                }
            } else if viewModel.mode == .video {
                // Video mode
                if viewModel.groupId == nil {
                    CallSetupScreen(viewModel: viewModel)
                } else {
                    CallingScreen(viewModel: viewModel)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
