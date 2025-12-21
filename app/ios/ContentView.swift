//
//  ContentView.swift
//  bgfx-simple-app
//
//  Main SwiftUI View
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        MetalView()
            .ignoresSafeArea()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                // Orientation changed - handled via MetalView coordinator
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                // Memory warning - handled via MetalView coordinator
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active && oldPhase == .background {
                    // Coming from background to foreground
                    // Will be handled in MetalView via applicationWillEnterForeground
                }
            }
    }
}

#Preview {
    ContentView()
}
