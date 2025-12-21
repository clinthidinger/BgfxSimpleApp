//
//  Renderer.swift
//  bgfx-simple-app
//
//  Metal renderer that interfaces with BasicApp C++
//

import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    private var metalView: MTKView
    private var basicApp: UnsafeMutableRawPointer?  // Points to C++ BasicApp

    init(metalView: MTKView) {
        self.metalView = metalView
        super.init()

        // Validate drawable size
        let size = metalView.drawableSize
        guard size.width.isFinite && size.height.isFinite &&
              size.width > 0 && size.height > 0 else {
            print("Warning: Invalid initial drawable size: \(size), using defaults")
            // Use screen size as fallback
            let screen = UIScreen.main
            let screenSize = screen.bounds.size
            let scale = screen.nativeScale
            let width = Int32(screenSize.width * scale)
            let height = Int32(screenSize.height * scale)
            let scaleFactor = Float(scale)

            basicApp = BasicAppBridge.create(
                withWidth: width,
                height: height,
                scaleFactor: scaleFactor,
                nwh: Unmanaged.passUnretained(metalView.layer).toOpaque(),
                device: Unmanaged.passUnretained(metalView.device!).toOpaque()
            )
            return
        }

        // Initialize BasicApp with valid size
        let width = Int32(size.width)
        let height = Int32(size.height)
        let scaleFactor = Float(metalView.contentScaleFactor)

        // Create BasicApp through bridge
        basicApp = BasicAppBridge.create(
            withWidth: width,
            height: height,
            scaleFactor: scaleFactor,
            nwh: Unmanaged.passUnretained(metalView.layer).toOpaque(),
            device: Unmanaged.passUnretained(metalView.device!).toOpaque()
        )
    }

    deinit {
        // Cleanup - but skip on iOS to avoid deadlock
        // if let app = basicApp {
        //     BasicAppBridge.destroy(app)
        // }
    }

    // MARK: - MTKViewDelegate

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        guard let app = basicApp else { return }

        // Validate size - skip if invalid
        guard size.width.isFinite && size.height.isFinite &&
              size.width > 0 && size.height > 0 else {
            print("Invalid drawable size: \(size)")
            return
        }

        BasicAppBridge.resize(
            app,
            width: Int32(size.width),
            height: Int32(size.height),
            scaleFactor: Float(view.contentScaleFactor)
        )
    }

    func draw(in view: MTKView) {
        guard let app = basicApp else { return }
        BasicAppBridge.update(app)
        BasicAppBridge.render(app)
    }
}
