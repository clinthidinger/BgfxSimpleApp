//
//  Renderer.m
//  ArtHUD
//
//  Created by clint hidinger on 12/11/19.
//  Copyright © 2019 me. All rights reserved.
//
#include <iostream>
#import <simd/simd.h>
#import <ModelIO/ModelIO.h>
#import "Renderer.h"
#import "GestureDelegate.h"
//#import "ShaderTypes.h"
#include "BgfxiOSAppLauncher.h"

//static const NSUInteger MaxBuffersInFlight = 3;

//self.view.paused = YES;
//self.view.manualRefreshMode = YES;

@implementation Renderer
{
    //dispatch_semaphore_t _inFlightSemaphore;
    id <MTLDevice> _device;
    NSTimer *_timer;
    GestureDelegate *_gestureDeleg;
}


- (void)dealloc
{
    BgfxiOSAppLauncher::instance().deleteApp();
    //[super dealloc]; // omit if using ARC
}

-(void) theAction {
  //[view setNeedsDisplay];
}

// see: https://stackoverflow.com/questions/57965701/statusbarorientation-was-deprecated-in-ios-13-0-when-attempting-to-get-app-ori
- (BOOL)isPortrait
{
    if (@available(iOS 13.0, *)) {
        UIWindow *firstWindow = [[[UIApplication sharedApplication] windows] firstObject];
        if (firstWindow == nil) {
            return NO;
        }
        UIWindowScene *windowScene = firstWindow.windowScene;
        if (windowScene == nil){
            return NO;
        }
        return UIInterfaceOrientationIsPortrait(windowScene.interfaceOrientation);
    } else {
        return (UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication.statusBarOrientation));
    }
}

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;
{
    self = [super init];
    if(self)
    {
        // TODO: check how much of this is handles by bgfx???
        _device = view.device;
        //!!!_inFlightSemaphore = dispatch_semaphore_create(MaxBuffersInFlight);
        view.depthStencilPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
        view.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
        view.sampleCount = 1;
        
        [view setContentMode:UIViewContentModeScaleToFill];
        auto screen = [UIScreen mainScreen];
        CGSize drawableSize = screen.bounds.size;
        drawableSize.width *= screen.nativeScale;
        drawableSize.height *= screen.nativeScale;
        view.contentScaleFactor = screen.nativeScale;
        view.drawableSize = drawableSize;
        
        //[self _setupGestures:view];
        
        //_bgfxApp = new BgfxApp( view.drawableSize.width, view.drawableSize.height, (__bridge void *)view.layer, (__bridge void *)view.device );
        auto *app = BgfxiOSAppLauncher::instance().getApp();
        app->init( view.drawableSize.width, view.drawableSize.height, view.contentScaleFactor, (__bridge void *)view.layer, (__bridge void *)view.device);//!!!, [self isPortrait] );
        if (!app->enableAutoRefresh())
        {
            // Turn off auto redraw.  Do view.setNeedsDisplay() to refresh.
            view.paused = true;
            view.enableSetNeedsDisplay = true;
            app->setRefreshFunc( [view] () { [view setNeedsDisplay]; } );
            app->setRefreshAtTimeFunc( [view, self] (float seconds) {
                if( _timer )
                {
                    [_timer invalidate];
                    //[_timer release];
                    _timer = nil;
                }
                // Wonder how much garbage we are generating
                _timer = [NSTimer scheduledTimerWithTimeInterval:seconds repeats:false block:^(NSTimer * _Nonnull timer) {
                     [view setNeedsDisplay];
                }];
             } );
            app->setAutoRefreshStateFunc( [view] (bool state) {
                view.paused = !state; view.enableSetNeedsDisplay = !state;
            } );
        }
    }

    return self;
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    /// Respond to drawable size or orientation changes here
    // Note: size will not have scale factor applied to it, but view.drawableSize should.
    // Has drawableSize already been adjusted?
    //auto msScale = [[UIScreen mainScreen] scale];
    //auto natScale = [[UIScreen mainScreen] nativeScale];
    //auto natBounds = [[UIScreen mainScreen] nativeBounds];
    
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->resize(view.drawableSize.width,
                view.drawableSize.height,
                view.contentScaleFactor );
}

- (void)drawInMTKView:(nonnull MTKView *)view
{
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->update();
    app->render();// view.drawableSize.width, view.drawableSize.height, view.contentScaleFactor, [self isPortrait] );
}

/*
// Should be in the GameViewController.
- (void)_setupGestures:(nonnull MTKView *)view
{
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    
    //UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    //swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;//   |
//    UISwipeGestureRecognizer *swipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
//    swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
//    UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
//    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;//   |
//    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
//    swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
        //UISwipeGestureRecognizerDirectionDown |
        //UISwipeGestureRecognizerDirectionLeft |
        //UISwipeGestureRecognizerDirectionRight;
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    
    
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:singleTapGestureRecognizer];
    [gestureRecognizers addObject:doubleTapGestureRecognizer];
    //[gestureRecognizers addObject:swipeUpGestureRecognizer];
    //[gestureRecognizers addObject:swipeDownGestureRecognizer];
    //[gestureRecognizers addObject:swipeLeftGestureRecognizer];
    //[gestureRecognizers addObject:swipeRightGestureRecognizer];
    [gestureRecognizers addObject:rotationGestureRecognizer]; // Possibly it is best to have this above pinch.
    [gestureRecognizers addObject:pinchGestureRecognizer];
    [gestureRecognizers addObject:panGestureRecognizer];
    
    //GestureDelegate *gestureDeleg = [[GestureDelegate alloc] init];
    _gestureDeleg = [[GestureDelegate alloc] init];
    [rotationGestureRecognizer setDelegate:_gestureDeleg];
    [pinchGestureRecognizer setDelegate:_gestureDeleg];
    [panGestureRecognizer setDelegate:_gestureDeleg];
    //[swipeUpGestureRecognizer setDelegate:_gestureDeleg];
    //[swipeDownGestureRecognizer setDelegate:_gestureDeleg];
    //[swipeLeftGestureRecognizer setDelegate:_gestureDeleg];
    //[swipeRightGestureRecognizer setDelegate:_gestureDeleg];
    _gestureDeleg.simultaneousGestureRecognizers = [gestureRecognizers copy];
    NSMutableArray *panGestureRecognizers = [NSMutableArray array];
    [panGestureRecognizers addObject:panGestureRecognizer];
    _gestureDeleg.panGestureRecognizers = [panGestureRecognizers copy];
    NSMutableArray *swipeGestureRecognizers = [NSMutableArray array];
    //[swipeGestureRecognizers addObject:swipeUpGestureRecognizer];
    //[swipeGestureRecognizers addObject:swipeDownGestureRecognizer];
    //[swipeGestureRecognizers addObject:swipeLeftGestureRecognizer];
    //[swipeGestureRecognizers addObject:swipeRightGestureRecognizer];
    _gestureDeleg.swipeGestureRecognizers = [swipeGestureRecognizers copy];
    
    //[panGestureRecognizer requireGestureRecognizerToFail:swipeUpGestureRecognizer];
    
    [singleTapGestureRecognizer requireGestureRecognizerToFail:rotationGestureRecognizer];
    [singleTapGestureRecognizer requireGestureRecognizerToFail:pinchGestureRecognizer];
    [singleTapGestureRecognizer requireGestureRecognizerToFail:panGestureRecognizer];
    //[singleTapGestureRecognizer requireGestureRecognizerToFail:swipeUpGestureRecognizer];
    //[singleTapGestureRecognizer requireGestureRecognizerToFail:swipeDownGestureRecognizer];
    //[singleTapGestureRecognizer requireGestureRecognizerToFail:swipeLeftGestureRecognizer];
    //[singleTapGestureRecognizer requireGestureRecognizerToFail:swipeRightGestureRecognizer];
    [doubleTapGestureRecognizer requireGestureRecognizerToFail:rotationGestureRecognizer];
    [doubleTapGestureRecognizer requireGestureRecognizerToFail:pinchGestureRecognizer];
    [doubleTapGestureRecognizer requireGestureRecognizerToFail:panGestureRecognizer];
    //[doubleTapGestureRecognizer requireGestureRecognizerToFail:swipeUpGestureRecognizer];
    //[doubleTapGestureRecognizer requireGestureRecognizerToFail:swipeDownGestureRecognizer];
    //[doubleTapGestureRecognizer requireGestureRecognizerToFail:swipeLeftGestureRecognizer];
    //[doubleTapGestureRecognizer requireGestureRecognizerToFail:swipeRightGestureRecognizer];
    
    //UIView *view = getWindow()->getNativeViewController().view;
    [gestureRecognizers addObjectsFromArray:view.gestureRecognizers];
    view.gestureRecognizers = gestureRecognizers;
}

- (void)removeAllGestures:(nonnull MTKView *)view
{
    for (UIGestureRecognizer *recognizer in view.gestureRecognizers)
    {
        [view removeGestureRecognizer:recognizer];
    }
}

-(void)enableSwipeGestures:(nonnull MTKView *)view :(bool)state
{
    for (UIGestureRecognizer *recognizer in view.gestureRecognizers) {
      if([recognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
        recognizer.enabled = state;
      }
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer*)gestureRecognizer
{
     CGPoint touchLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
     auto *app = BgfxiOSAppLauncher::instance().getApp();
     app->handleSingleTap( touchLocation.x, touchLocation.y );
}

- (void)handleDoubleTap:(UITapGestureRecognizer*)gestureRecognizer
{
    CGPoint touchLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->handleDoubleTap( touchLocation.x, touchLocation.y );
}

- (void)handleSwipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    CGPoint touchLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->handleSwipe( touchLocation.x, touchLocation.y,
                      static_cast<int>( gestureRecognizer.direction ) );
}

- (void)handlePinch:(UIPinchGestureRecognizer*)gestureRecognizer
{
    CGPoint anchor = [gestureRecognizer locationInView:gestureRecognizer.view];
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->handlePinch( anchor.x, anchor.y, gestureRecognizer.scale );
    [gestureRecognizer setScale:1.0f];
}

- (void)handlePan:(UIPanGestureRecognizer*)gestureRecognizer
{
    CGPoint touchLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    unsigned long numTouches = [gestureRecognizer numberOfTouches];
    CGPoint velocity = [gestureRecognizer velocityInView: gestureRecognizer.view];
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->handlePan( touchLocation.x, touchLocation.y,
                    translation.x, translation.y,
                    velocity.x, velocity.y,
                    static_cast<int>( numTouches ) );
    [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
}

- (void)handleRotation:(UIRotationGestureRecognizer*)gestureRecognizer
{
    CGPoint anchor = [gestureRecognizer locationInView:gestureRecognizer.view];
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->handleRotation( anchor.x, anchor.y, gestureRecognizer.rotation );
    [gestureRecognizer setRotation:0.0f];
}
*/
@end
