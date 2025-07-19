//
//  main.mm
//
//  Created by clint hidinger on 1/2/20.
//  Copyright © 2020 me. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OSXAppDelegate.h"
#include "BgfxOSXAppLauncher.h"
#include "BgfxSimpleApp.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Setup the app instance
        BgfxOSXAppLauncher::instance().setApp(new BgfxSimpleApp());
        
        NSApplication *app = [NSApplication sharedApplication];
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];
        
        OSXAppDelegate *delegate = [[OSXAppDelegate alloc] init];
        [app setDelegate:delegate];
        
        [app run];
    }
    return 0;
}
