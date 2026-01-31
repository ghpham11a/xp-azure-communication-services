//
//  AcsConfig.swift
//  AzureCommunication
//

import Foundation

enum AcsConfig {
    // Azure Communication Services endpoint
    // Get this from Azure Portal -> Your ACS Resource -> Keys -> Endpoint
    static let acsEndpoint = "https://template-qa-azcs.unitedstates.communication.azure.com"

    // Backend API base URL (use ngrok for mobile testing)
    static let apiBaseURL = "https://feedback-test.ngrok.io"
}
