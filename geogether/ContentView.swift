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
        WelcomeView()
    }
}

#Preview {
    ContentView()
        .environmentObject(ProgressStore())
}
