//
//  OSXAppDelegate.mm
//
//  Created by clint hidinger on 1/2/20.
//  Copyright © 2020 me. All rights reserved.
//

#import "OSXAppDelegate.h"
#import "OSXViewController.h"
#include "BgfxOSXAppLauncher.h"

@implementation OSXAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Create the main window
    NSRect windowFrame = NSMakeRect(100, 100, 1024, 768);
    
    self.window = [[NSWindow alloc] initWithContentRect:windowFrame
                                              styleMask:(NSWindowStyleMaskTitled | 
                                                       NSWindowStyleMaskClosable | 
                                                       NSWindowStyleMaskMiniaturizable | 
                                                       NSWindowStyleMaskResizable)
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    
    [self.window setTitle:@"Bgfx Simple App"];
    [self.window makeKeyAndOrderFront:nil];
    [self.window center];
    
    // Create and set the view controller
    self.viewController = [[OSXViewController alloc] init];
    [self.window setContentViewController:self.viewController];
    
    // Notify the app
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        app->didFinishLaunching();
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        app->willTerminate();
        //app->shutdown();
    }
    BgfxOSXAppLauncher::instance().deleteApp();
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        app->didBecomeActive();
    }
}

- (void)applicationWillResignActive:(NSNotification *)aNotification {
    IBgfxOSXApp* app = BgfxOSXAppLauncher::instance().getApp();
    if (app) {
        app->willResignActive();
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
