//
//  OSXViewController.h
//
//  Created by clint hidinger on 1/2/20.
//  Copyright © 2020 me. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetalKit/MetalKit.h>

@interface OSXViewController : NSViewController

@property (strong, nonatomic) MTKView* metalView;

@end