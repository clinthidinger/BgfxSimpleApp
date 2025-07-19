//
//  main.m
//  ArtHUD
//
//  Created by clint hidinger on 12/11/19.
//  Copyright © 2019 me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#include "BgfxiOSAppLauncher.h"
#include "BgfxApp.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    BgfxiOSAppLauncher::instance().setApp( new BgfxApp() );
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
