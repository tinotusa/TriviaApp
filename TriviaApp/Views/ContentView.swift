//
//  ContentView.swift
//  TriviaApp
//
//  Created by Tino on 4/12/2022.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var hapticManager: HapticsManager
    
    var body: some View {
        HomeView()
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .active:
                    hapticManager.restartEngine()
                case .background:
                    print("App entered background.")
                case .inactive:
                    print("App is inactive.")
                @unknown default:
                    print("unknown scene phase.")
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HapticsManager())
    }
}
