//
//  HomeViewModel.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import Foundation
import os

/// View model for HomeView.
final class HomeViewModel: ObservableObject {
    @Published var triviaConfig = TriviaAPI.TriviaConfig.default
    private let log = Logger(subsystem: "com.tinotusa.TriviaApp", category: "HomeViewModel")
}
