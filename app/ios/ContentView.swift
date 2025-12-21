//
//  ContentView.swift
//  bgfx-simple-app
//
//  Main SwiftUI View
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MetalView()
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
