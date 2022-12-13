//
//  TokenResponse.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import Foundation

struct TokenResponse: Codable {
    let responseCode: Int
    let responseMessage: String
    let token: String
}
