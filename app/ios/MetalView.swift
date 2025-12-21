//
//  MetalView.swift
//  bgfx-simple-app
//
//  SwiftUI wrapper for MTKView
//

import SwiftUI
import MetalKit

struct MetalView: UIViewRepresentable {
    @Environment(\.scenePhase) private var scenePhase

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

        // Set up gesture recognizers
        setupGestures(for: mtkView, coordinator: context.coordinator)

        // Call viewDidLoad and applicationDidFinishLaunching
        if let app = renderer.basicApp {
            BasicAppBridge.viewDidLoad(app)
            BasicAppBridge.applicationDidFinishLaunching(app)
        }

        // Set up notification observers in coordinator
        context.coordinator.setupNotifications()

        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        // Handle scene phase changes for app lifecycle
        guard let renderer = context.coordinator.renderer,
              let app = renderer.basicApp else { return }

        // Track previous phase to detect transitions
        let previousPhase = context.coordinator.previousPhase
        context.coordinator.previousPhase = scenePhase

        switch scenePhase {
        case .active:
            if previousPhase == .background {
                BasicAppBridge.applicationWillEnterForeground(app)
            }
            BasicAppBridge.applicationDidBecomeActive(app)
        case .inactive:
            BasicAppBridge.applicationWillResignActive(app)
        case .background:
            BasicAppBridge.applicationDidEnterBackground(app)
        @unknown default:
            break
        }
    }

    private func setupGestures(for view: MTKView, coordinator: Coordinator) {
        // Single tap
        let singleTap = UITapGestureRecognizer(target: coordinator, action: #selector(Coordinator.handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTap)

        // Double tap
        let doubleTap = UITapGestureRecognizer(target: coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        singleTap.require(toFail: doubleTap)

        // Pan
        let pan = UIPanGestureRecognizer(target: coordinator, action: #selector(Coordinator.handlePan(_:)))
        view.addGestureRecognizer(pan)

        // Pinch
        let pinch = UIPinchGestureRecognizer(target: coordinator, action: #selector(Coordinator.handlePinch(_:)))
        view.addGestureRecognizer(pinch)

        // Rotation
        let rotation = UIRotationGestureRecognizer(target: coordinator, action: #selector(Coordinator.handleRotation(_:)))
        view.addGestureRecognizer(rotation)

        // Swipe
        for direction in [UISwipeGestureRecognizer.Direction.left, .right, .up, .down] {
            let swipe = UISwipeGestureRecognizer(target: coordinator, action: #selector(Coordinator.handleSwipe(_:)))
            swipe.direction = direction
            view.addGestureRecognizer(swipe)
        }
    }

    class Coordinator: NSObject {
        var renderer: Renderer?
        var previousPhase: ScenePhase = .inactive

        func setupNotifications() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(orientationDidChange),
                name: UIDevice.orientationDidChangeNotification,
                object: nil
            )

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didReceiveMemoryWarning),
                name: UIApplication.didReceiveMemoryWarningNotification,
                object: nil
            )
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        @objc func orientationDidChange() {
            guard let app = renderer?.basicApp else { return }
            BasicAppBridge.handleChangeOrientation(app)
        }

        @objc func didReceiveMemoryWarning() {
            guard let app = renderer?.basicApp else { return }
            BasicAppBridge.didReceiveMemoryWarning(app)
        }

        @objc func handleSingleTap(_ gesture: UITapGestureRecognizer) {
            guard let app = renderer?.basicApp else { return }
            let location = gesture.location(in: gesture.view)
            BasicAppBridge.handleSingleTap(app, x: Float(location.x), y: Float(location.y))
        }

        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let app = renderer?.basicApp else { return }
            let location = gesture.location(in: gesture.view)
            BasicAppBridge.handleDoubleTap(app, x: Float(location.x), y: Float(location.y))
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let app = renderer?.basicApp, let view = gesture.view else { return }
            let location = gesture.location(in: view)
            let translation = gesture.translation(in: view)
            let velocity = gesture.velocity(in: view)
            BasicAppBridge.handlePan(app,
                x: Float(location.x), y: Float(location.y),
                translationX: Float(translation.x), translationY: Float(translation.y),
                velocityX: Float(velocity.x), velocityY: Float(velocity.y),
                numTouches: Int32(gesture.numberOfTouches))
        }

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let app = renderer?.basicApp else { return }
            let location = gesture.location(in: gesture.view)
            BasicAppBridge.handlePinch(app, x: Float(location.x), y: Float(location.y), scale: Float(gesture.scale))
        }

        @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
            guard let app = renderer?.basicApp else { return }
            let location = gesture.location(in: gesture.view)
            BasicAppBridge.handleRotation(app, x: Float(location.x), y: Float(location.y), rotation: Float(gesture.rotation))
        }

        @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
            guard let app = renderer?.basicApp else { return }
            let location = gesture.location(in: gesture.view)
            let direction: Int32 = {
                switch gesture.direction {
                case .left: return 0
                case .right: return 1
                case .up: return 2
                case .down: return 3
                default: return 0
                }
            }()
            BasicAppBridge.handleSwipe(app, x: Float(location.x), y: Float(location.y), direction: direction)
        }
    }
}
