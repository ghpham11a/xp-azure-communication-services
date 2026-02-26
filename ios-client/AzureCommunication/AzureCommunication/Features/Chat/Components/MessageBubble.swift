//
//  MessageBubble.swift
//  AzureCommunication
//
//  Created by Anthony Pham on 2/25/26.
//

import SwiftUI

struct ChatMessageItem: Identifiable {
    let id: String
    let content: String
    let senderDisplayName: String
    let senderId: String
    let createdOn: Date
}

struct MessageBubble: View {
    let message: ChatMessageItem
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                if !isCurrentUser {
                    Text(message.senderDisplayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(message.content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isCurrentUser ? Color.accentColor : Color(.secondarySystemBackground))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .cornerRadius(16)
            }

            if !isCurrentUser { Spacer() }
        }
    }
}
