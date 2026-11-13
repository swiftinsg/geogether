//
//  geogetherApp.swift
//  geogether
//
//  Created by Val on 13/11/26.
//

import SwiftUI

@main
struct geogetherApp: App {
    @StateObject private var progress = ProgressStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(progress)
                .tint(TopicTint.teal.color)
        }
    }
}
