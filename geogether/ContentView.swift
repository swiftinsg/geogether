//
//  ContentView.swift
//  geogether
//
//  Created by Val on 13/11/26.
//

import SwiftUI

/// Root screen of the app: the Geography simulation question bank,
/// split into six topics. Each question is shown on its own page.
struct ContentView: View {
    var body: some View {
        TopicListView()
    }
}

#Preview {
    ContentView()
        .environmentObject(ProgressStore())
}
