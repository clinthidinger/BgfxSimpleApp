//
//  MetalView.swift
//  bgfx-simple-app
//
//  SwiftUI wrapper for MTKView
//

import SwiftUI
import MetalKit

struct MetalView: UIViewRepresentable {

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()

        // Create Metal device
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }

        mtkView.device = device
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        mtkView.depthStencilPixelFormat = .depth32Float_stencil8
        mtkView.sampleCount = 1

        // Configure for screen
        let screen = UIScreen.main
        var drawableSize = screen.bounds.size
        drawableSize.width *= screen.nativeScale
        drawableSize.height *= screen.nativeScale
        mtkView.contentScaleFactor = screen.nativeScale
        mtkView.drawableSize = drawableSize

        // Create and set up renderer
        let renderer = Renderer(metalView: mtkView)
        mtkView.delegate = renderer

        // Store renderer in coordinator to keep it alive
        context.coordinator.renderer = renderer

        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        // Handle updates if needed
    }

    class Coordinator {
        var renderer: Renderer?
    }
}
