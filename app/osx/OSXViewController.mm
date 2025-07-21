//
//  OSXViewController.mm
//
//  Created by clint hidinger on 1/2/20.
//  Copyright © 2020 me. All rights reserved.
//

#import "OSXViewController.h"
#include "BgfxOSXAppLauncher.h"
#import <Carbon/Carbon.h>

@interface OSXViewController () <MTKViewDelegate>
@property (nonatomic, assign) BOOL needsRefresh;
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@end

@implementation OSXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create Metal view
    self.metalView = [[MTKView alloc] initWithFrame:self.view.bounds];
    self.metalView.delegate = self;
    self.metalView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.metalView.paused = YES;
    self.metalView.enableSetNeedsDisplay = NO;
    
    [self.view addSubview:self.metalView];
    
    // Setup tracking area for mouse events
    [self updateTrackingAreas];
    
    // Setup trackpad gesture recognizers
    [self setupTrackpadGestures];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        NSRect bounds = self.metalView.bounds;
        CGFloat scaleFactor = self.view.window.backingScaleFactor;
        
        app->init((int)bounds.size.width, (int)bounds.size.height, 
                 (float)scaleFactor, (__bridge void*)self.metalView, 
                 (__bridge void*)self.metalView.device);
        
        // Setup refresh callback
        __weak typeof(self) weakSelf = self;
        app->setRefreshFunc([weakSelf]() {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.needsRefresh = YES;
                [weakSelf.metalView setNeedsDisplay:YES];
            });
        });
        
        app->setAutoRefreshStateFunc([weakSelf](bool autoRefresh) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.metalView.paused = !autoRefresh;
            });
        });
        
        if (app->enableAutoRefresh()) {
            self.metalView.paused = NO;
        }
    }
}

- (void)viewDidLayout {
    [super viewDidLayout];
    
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        NSRect bounds = self.metalView.bounds;
        CGFloat scaleFactor = self.view.window.backingScaleFactor;
        app->resize((int)bounds.size.width, (int)bounds.size.height, (float)scaleFactor);
    }
}


#pragma mark - MTKViewDelegate

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        CGFloat scaleFactor = self.view.window.backingScaleFactor;
        app->resize((int)size.width, (int)size.height, (float)scaleFactor);
    }
}

- (void)drawInMTKView:(MTKView *)view {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        app->update();
        app->render();
    }
}

#pragma mark - Mouse Events

- (void)updateTrackingAreas {
    if (self.trackingArea) {
        [self.view removeTrackingArea:self.trackingArea];
    }
    
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.view.bounds
                                                     options:(NSTrackingMouseMoved | NSTrackingActiveInKeyWindow)
                                                       owner:self
                                                    userInfo:nil];
    [self.view addTrackingArea:self.trackingArea];
}

- (void)mouseDown:(NSEvent *)event {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        NSPoint location = [self.metalView convertPoint:[event locationInWindow] fromView:nil];
        app->handleMouseDown(0, (float)location.x, (float)location.y);
    }
}

- (void)mouseUp:(NSEvent *)event {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        NSPoint location = [self.metalView convertPoint:[event locationInWindow] fromView:nil];
        app->handleMouseUp(0, (float)location.x, (float)location.y);
    }
}

- (void)mouseDragged:(NSEvent *)event {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        NSPoint location = [self.metalView convertPoint:[event locationInWindow] fromView:nil];
        app->handleMouseDrag(0, (float)location.x, (float)location.y);
    }
}

- (void)mouseMoved:(NSEvent *)event {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        NSPoint location = [self.metalView convertPoint:[event locationInWindow] fromView:nil];
        app->handleMouseMove((float)location.x, (float)location.y);
    }
}

- (void)rightMouseDown:(NSEvent *)event {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        NSPoint location = [self.metalView convertPoint:[event locationInWindow] fromView:nil];
        app->handleMouseDown(1, (float)location.x, (float)location.y);
    }
}

- (void)rightMouseUp:(NSEvent *)event {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        NSPoint location = [self.metalView convertPoint:[event locationInWindow] fromView:nil];
        app->handleMouseUp(1, (float)location.x, (float)location.y);
    }
}

- (void)rightMouseDragged:(NSEvent *)event {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        NSPoint location = [self.metalView convertPoint:[event locationInWindow] fromView:nil];
        app->handleMouseDrag(1, (float)location.x, (float)location.y);
    }
}

- (void)scrollWheel:(NSEvent *)event {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        NSPoint location = [self.metalView convertPoint:[event locationInWindow] fromView:nil];
        app->handleMouseWheel((float)location.x, (float)location.y, 
                             (float)[event scrollingDeltaX]); //, (float)[event scrollingDeltaY]
    }
}

#pragma mark - Key Events

- (void)keyDown:(NSEvent *)event {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        int keyMods = 0;
        if ([event modifierFlags] & NSEventModifierFlagShift) keyMods |= (int)IBgfxOSXApp::KeyModifier::SHIFT_DOWN;
        if ([event modifierFlags] & NSEventModifierFlagControl) keyMods |= (int)IBgfxOSXApp::KeyModifier::CTRL_DOWN;
        if ([event modifierFlags] & NSEventModifierFlagOption) keyMods |= (int)IBgfxOSXApp::KeyModifier::ALT_DOWN;
        if ([event modifierFlags] & NSEventModifierFlagCommand) keyMods |= (int)IBgfxOSXApp::KeyModifier::META_DOWN;
        
        app->handleKeyDown([event keyCode], keyMods);
    }
}

- (void)keyUp:(NSEvent *)event {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        int keyMods = 0;
        if ([event modifierFlags] & NSEventModifierFlagShift) keyMods |= (int)IBgfxOSXApp::KeyModifier::SHIFT_DOWN;
        if ([event modifierFlags] & NSEventModifierFlagControl) keyMods |= (int)IBgfxOSXApp::KeyModifier::CTRL_DOWN;
        if ([event modifierFlags] & NSEventModifierFlagOption) keyMods |= (int)IBgfxOSXApp::KeyModifier::ALT_DOWN;
        if ([event modifierFlags] & NSEventModifierFlagCommand) keyMods |= (int)IBgfxOSXApp::KeyModifier::META_DOWN;
        
        app->handleKeyUp([event keyCode], keyMods);
    }
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

#pragma mark - Trackpad Gesture Setup

- (void)setupTrackpadGestures {
    // Pinch/Zoom gesture (trackpad pinch)
    NSMagnificationGestureRecognizer *magnifyGesture = [[NSMagnificationGestureRecognizer alloc] initWithTarget:self action:@selector(handleMagnification:)];
    [self.view addGestureRecognizer:magnifyGesture];
    
    // Rotation gesture (trackpad rotate)
    NSRotationGestureRecognizer *rotationGesture = [[NSRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    [self.view addGestureRecognizer:rotationGesture];
    
    // Two-finger swipe gestures
    // Note: For swipe gestures, you might want to use the scrollWheel: method instead
    // as it provides better granular control over trackpad scrolling
    
    // Pan gesture (trackpad drag with multiple fingers)
    NSPanGestureRecognizer *panGesture = [[NSPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [panGesture setButtonMask:0]; // Allow gestures without mouse button pressed
    [self.view addGestureRecognizer:panGesture];
    
    // Click gesture (trackpad tap)
    NSClickGestureRecognizer *clickGesture = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(handleClick:)];
    [self.view addGestureRecognizer:clickGesture];
}

#ifdef ENABLE_GESTURES
#pragma mark - Trackpad Gesture Handlers

- (void)handleMagnification:(NSMagnificationGestureRecognizer *)recognizer {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        NSPoint location = [recognizer locationInView:self.metalView];
        // Convert magnification to scale factor (1.0 + magnification)
        float scale = 1.0f + (float)recognizer.magnification;
        app->handlePinch(0, (float)location.x, (float)location.y, scale);
        
        // Reset magnification to prevent accumulation
        recognizer.magnification = 0.0;
    }
}

- (void)handleRotation:(NSRotationGestureRecognizer *)recognizer {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        NSPoint location = [recognizer locationInView:self.metalView];
        app->handleRotation((float)location.x, (float)location.y, (float)recognizer.rotation);
        
        // Reset rotation to prevent accumulation
        recognizer.rotation = 0.0;
    }
}

- (void)handlePanGesture:(NSPanGestureRecognizer *)recognizer {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        NSPoint location = [recognizer locationInView:self.metalView];
        NSPoint translation = [recognizer translationInView:self.metalView];
        
        // Simulate pan gesture similar to iOS
        app->handlePan((float)location.x, (float)location.y, 
                      (float)translation.x, (float)translation.y,
                      0.0f, 0.0f, 1); // velocity = 0, numTouches = 1
        
        // Reset translation to prevent accumulation
        [recognizer setTranslation:NSZeroPoint inView:self.metalView];
    }
}

- (void)handleClick:(NSClickGestureRecognizer *)recognizer {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        NSPoint location = [recognizer locationInView:self.metalView];
        
        if (recognizer.numberOfClicksRequired == 1) {
            app->handleSingleTap((float)location.x, (float)location.y);
        } else if (recognizer.numberOfClicksRequired == 2) {
            app->handleDoubleTap((float)location.x, (float)location.y);
        }
    }
}

#endif

@end
