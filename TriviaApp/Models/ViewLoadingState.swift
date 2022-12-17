//
//  ViewLoadingState.swift
//  TriviaApp
//
//  Created by Tino on 17/12/2022.
//

import Foundation

/// The loading state a view.
enum ViewLoadingState {
    case loading
    case loaded
    case error(error: Error)
}
