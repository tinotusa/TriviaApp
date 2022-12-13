//
//  TriviaAppApp.swift
//  TriviaApp
//
//  Created by Tino on 4/12/2022.
//

import SwiftUI

@main
struct TriviaAppApp: App {
    @StateObject private var homeViewModel = HomeViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(homeViewModel)
        }
    }
}
