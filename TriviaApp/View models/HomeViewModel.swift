//
//  HomeViewModel.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import Foundation
import os
import SwiftOpenTDB

/// View model for HomeView.
final class HomeViewModel: ObservableObject {
    @Published var triviaConfig = TriviaConfig.default
    private let log = Logger(subsystem: "com.tinotusa.TriviaApp", category: "HomeViewModel")
    
    var startDisabled: Bool {
        triviaConfig.numberOfQuestions == 0
    }
}
