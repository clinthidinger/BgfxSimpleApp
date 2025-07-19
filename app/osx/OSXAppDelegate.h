//
//  OSXAppDelegate.h
//
//  Created by clint hidinger on 1/2/20.
//  Copyright © 2020 me. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OSXViewController;

@interface OSXAppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NSWindow *window;
@property (strong, nonatomic) OSXViewController *viewController;

@end