//
//  BgfxSimpleApp.swift
//  bgfx-simple-app
//
//  SwiftUI App Entry Point
//

import SwiftUI

@main
struct BgfxSimpleApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Note: App lifecycle methods are called via ContentView
            // since we need access to the BasicApp instance
        }
    }
}
