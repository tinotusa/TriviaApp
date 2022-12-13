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
        case serverError(code: Int)
        case responseError(code: ResponseCode)
        case unknownError
    }
    
    /// Responses from the opentdb api.
    enum ResponseCode: Int {
        /// Returned results successfully.
        case success
        /// Could not return results. The API doesn't have enough questions for your query.
        case noResults
        /// Parameter Contains an invalid parameter. Arguments passed in aren't valid.
        case invalidParameter
        /// Session Token does not exist.
        case tokenNotFound
        /// Session Token has returned all possible questions for the specified query. Resetting the Token is necessary.
        case tokenEmpty
    }
}
