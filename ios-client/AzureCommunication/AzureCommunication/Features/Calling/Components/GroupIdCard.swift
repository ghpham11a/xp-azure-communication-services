//
//  GroupIdCard.swift
//  AzureCommunication
//
//  Created by Anthony Pham on 2/25/26.
//

import SwiftUI

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
