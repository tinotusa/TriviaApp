//
//  TriviaAppApp.swift
//  TriviaApp
//
//  Created by Tino on 4/12/2022.
//

import SwiftUI

@main
struct TriviaAppApp: App {
    @AppStorage("sessionToken") private var sessionToken: String = ""
    @StateObject private var hapticManger = HapticsManager()
    
    init() {
        if !sessionToken.isEmpty {
            TriviaAPI.shared.sessionToken = sessionToken
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(hapticManger)
        }
    }
}
