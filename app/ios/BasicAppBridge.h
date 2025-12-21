//
//  BasicAppBridge.h
//  bgfx-simple-app
//
//  Objective-C bridge to C++ BasicApp for Swift interop
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BasicAppBridge : NSObject

+ (void *)createWithWidth:(int)width
                   height:(int)height
              scaleFactor:(float)scaleFactor
                      nwh:(void *)nwh
                   device:(void *)device;

+ (void)destroy:(void *)app;

+ (void)update:(void *)app;

+ (void)render:(void *)app;

+ (void)resize:(void *)app
         width:(int)width
        height:(int)height
   scaleFactor:(float)scaleFactor;

// Gesture handlers
+ (void)handleChangeOrientation:(void *)app;
+ (void)handleSwipe:(void *)app x:(float)x y:(float)y direction:(int)direction;
+ (void)handleSingleTap:(void *)app x:(float)x y:(float)y;
+ (void)handleDoubleTap:(void *)app x:(float)x y:(float)y;
+ (void)handlePan:(void *)app x:(float)x y:(float)y translationX:(float)translationX translationY:(float)translationY velocityX:(float)velocityX velocityY:(float)velocityY numTouches:(int)numTouches;
+ (void)handlePinch:(void *)app x:(float)x y:(float)y scale:(float)scale;
+ (void)handleRotation:(void *)app x:(float)x y:(float)y rotation:(float)rotation;

// Input handlers
+ (void)handleKeyDown:(void *)app keyCode:(int)keyCode;
+ (void)handleKeyUp:(void *)app keyCode:(int)keyCode;
+ (void)handleMouseDown:(void *)app x:(float)x y:(float)y button:(int)button;
+ (void)handleMouseUp:(void *)app x:(float)x y:(float)y button:(int)button;
+ (void)handleMouseMove:(void *)app x:(float)x y:(float)y;
+ (void)handleMouseWheel:(void *)app x:(float)x y:(float)y deltaX:(float)deltaX deltaY:(float)deltaY;

// Lifecycle methods
+ (void)viewDidLoad:(void *)app;
+ (void)viewWillAppear:(void *)app;
+ (void)viewWillDisappear:(void *)app;
+ (void)viewDidDisappear:(void *)app;
+ (void)viewWillTransitionToSize:(void *)app;
+ (void)viewDidLayoutSubviews:(void *)app;
+ (void)applicationDidBecomeActive:(void *)app;
+ (void)applicationWillResignActive:(void *)app;
+ (void)applicationDidEnterBackground:(void *)app;
+ (void)applicationWillEnterForeground:(void *)app;
+ (void)applicationDidFinishLaunching:(void *)app;
+ (void)didReceiveMemoryWarning:(void *)app;

@end

NS_ASSUME_NONNULL_END
