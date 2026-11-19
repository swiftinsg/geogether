//
//  ContentView.swift
//  geogether
//
//  Created by Val on 13/11/26.
//

import SwiftUI

/// Root screen of the app.
struct ContentView: View {
    var body: some View {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--water-cycle-preview") {
            WaterCycleView()
        } else {
            WelcomeView()
        }
        #else
        WelcomeView()
        #endif
    }
}

#Preview {
    ContentView()
        .environmentObject(ProgressStore())
}
