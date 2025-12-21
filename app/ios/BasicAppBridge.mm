//
//  BasicAppBridge.mm
//  bgfx-simple-app
//
//  Objective-C++ implementation bridging to C++ BasicApp
//

#import "BasicAppBridge.h"
#import "../../src/BasicApp.h"

@implementation BasicAppBridge

+ (void *)createWithWidth:(int)width
                   height:(int)height
              scaleFactor:(float)scaleFactor
                      nwh:(void *)nwh
                   device:(void *)device {
    BasicApp *app = new BasicApp();
    app->init(width, height, scaleFactor, nwh, device);
    return app;
}

+ (void)destroy:(void *)app {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        delete basicApp;
    }
}

+ (void)update:(void *)app {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->update();
    }
}

+ (void)render:(void *)app {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->render();
    }
}

+ (void)resize:(void *)app
         width:(int)width
        height:(int)height
   scaleFactor:(float)scaleFactor {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->resize(width, height, scaleFactor);
    }
}

// Gesture handlers
+ (void)handleChangeOrientation:(void *)app {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->handleChangeOrientation();
    }
}

+ (void)handleSwipe:(void *)app x:(float)x y:(float)y direction:(int)direction {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->handleSwipe(x, y, direction);
    }
}

+ (void)handleSingleTap:(void *)app x:(float)x y:(float)y {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->handleSingleTap(x, y);
    }
}

+ (void)handleDoubleTap:(void *)app x:(float)x y:(float)y {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->handleDoubleTap(x, y);
    }
}

+ (void)handlePan:(void *)app x:(float)x y:(float)y translationX:(float)translationX translationY:(float)translationY velocityX:(float)velocityX velocityY:(float)velocityY numTouches:(int)numTouches {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->handlePan(x, y, translationX, translationY, velocityX, velocityY, numTouches);
    }
}

+ (void)handlePinch:(void *)app x:(float)x y:(float)y scale:(float)scale {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->handlePinch(x, y, scale);
    }
}

+ (void)handleRotation:(void *)app x:(float)x y:(float)y rotation:(float)rotation {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->handleRotation(x, y, rotation);
    }
}

// Input handlers
+ (void)handleKeyDown:(void *)app keyCode:(int)keyCode {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->handleKeyDown(keyCode);
    }
}

+ (void)handleKeyUp:(void *)app keyCode:(int)keyCode {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->handleKeyUp(keyCode);
    }
}

+ (void)handleMouseDown:(void *)app x:(float)x y:(float)y button:(int)button {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->handleMouseDown(x, y, button);
    }
}

+ (void)handleMouseUp:(void *)app x:(float)x y:(float)y button:(int)button {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->handleMouseUp(x, y, button);
    }
}

+ (void)handleMouseMove:(void *)app x:(float)x y:(float)y {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->handleMouseMove(x, y);
    }
}

+ (void)handleMouseWheel:(void *)app x:(float)x y:(float)y deltaX:(float)deltaX deltaY:(float)deltaY {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->handleMouseWheel(x, y, deltaX, deltaY);
    }
}

// Lifecycle methods
+ (void)viewDidLoad:(void *)app {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->viewDidLoad();
    }
}

+ (void)viewWillAppear:(void *)app {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->viewWillAppear();
    }
}

+ (void)viewWillDisappear:(void *)app {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->viewWillDisappear();
    }
}

+ (void)viewDidDisappear:(void *)app {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->viewDidDisappear();
    }
}

+ (void)viewWillTransitionToSize:(void *)app {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->viewWillTransitionToSize();
    }
}

+ (void)viewDidLayoutSubviews:(void *)app {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->viewDidLayoutSubviews();
    }
}

+ (void)applicationDidBecomeActive:(void *)app {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->applicationDidBecomeActive();
    }
}

+ (void)applicationWillResignActive:(void *)app {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->applicationWillResignActive();
    }
}

+ (void)applicationDidEnterBackground:(void *)app {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->applicationDidEnterBackground();
    }
}

+ (void)applicationWillEnterForeground:(void *)app {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->applicationWillEnterForeground();
    }
}

+ (void)applicationDidFinishLaunching:(void *)app {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->applicationDidFinishLaunching();
    }
}

+ (void)didReceiveMemoryWarning:(void *)app {
    if (app) {
        BasicApp *basicApp = static_cast<BasicApp *>(app);
        basicApp->didReceivememoryWarning();
    }
}

@end
