//
//  TriviaAPIError.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import Foundation

extension TriviaAPI {
    enum TriviaAPIError: Error {
        case invalidURL
        case serverStatus(code: Int)
        case invalidAPIResponse(code: ResponseCode)
        case unknownError
        // api response errors
        case noSessonToken
        case noResults
        case seenAllQuestions
        case invalidParameter
    }
    
    /// Responses from the opentdb api.
    enum ResponseCode: Int, CustomStringConvertible {
        /// Returned results successfully.
        case success = 0
        /// Could not return results. The API doesn't have enough questions for your query.
        case noResults = 1
        /// Parameter Contains an invalid parameter. Arguments passed in aren't valid.
        case invalidParameter = 2
        /// Session Token does not exist.
        case tokenNotFound = 3
        /// Session Token has returned all possible questions for the specified query. Resetting the Token is necessary.
        case tokenEmpty = 4
        
        var description: String {
            switch self {
            case .success:
                return "Returned results successfully."
            case .noResults:
                return "Could not return results. The API doesn't have enough questions for your query. (Ex. Asking for 50 Questions in a Category that only has 20.)"
            case .invalidParameter:
                return "Contains an invalid parameter. Arguments passed in aren't valid. (Ex. Amount = Five)"
            case .tokenNotFound:
                return "Session Token does not exist."
            case .tokenEmpty:
                return "Token has returned all possible questions for the specified query. Resetting the Token is necessary."
            }
        }
    }
}
