//
//  ThreadIdCard.swift
//  AzureCommunication
//
//  Created by Anthony Pham on 2/25/26.
//

import SwiftUI

struct ThreadIdCard: View {
    let threadId: String

    var body: some View {
        VStack(spacing: 8) {
            Text("Thread ID")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(threadId)
                .font(.system(.caption, design: .monospaced))
                .multilineTextAlignment(.center)
            Button("Copy to Clipboard") {
                UIPasteboard.general.string = threadId
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
