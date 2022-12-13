//
//  TokenResponse.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import Foundation

/// Model for opentdb token response.
struct TokenResponse: Codable {
    /// The response code of the request.
    let responseCode: Int
    /// The response message of the request.
    let responseMessage: String
    /// The token of the request.
    let token: String
}
