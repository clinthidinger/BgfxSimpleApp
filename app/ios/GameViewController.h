//
//  GameViewController.h
//  ArtHUD
//
//  Created by clint hidinger on 12/11/19.
//  Copyright © 2019 me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import "Renderer.h"

// Our iOS view controller - now handles gestures directly
@interface GameViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

- (void)handleKeyDown:(NSInteger)keyCode;
- (void)handleKeyUp:(NSInteger)keyCode;
- (void)handleMouseDown:(CGPoint)location button:(NSInteger)button;
- (void)handleMouseUp:(CGPoint)location button:(NSInteger)button;
- (void)handleMouseDrag:(CGPoint)location;
- (void)handleMouseWheel:(CGFloat)deltaX deltaY:(CGFloat)deltaY;

// Window management stays in the view controller
- (CGFloat)getWidth;
- (CGFloat)getHeight;
- (void)setWidth:(CGFloat)width height:(CGFloat)height;
@end
