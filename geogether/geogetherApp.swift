//
//  geogetherApp.swift
//  geogether
//
//  Created by Val on 13/11/26.
//

import SwiftUI

@main
struct geogetherApp: App {
    @StateObject private var touchGlobe = TouchGlobeState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(touchGlobe)
        }
    }
}
