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

@end

NS_ASSUME_NONNULL_END
