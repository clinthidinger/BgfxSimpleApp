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

@end
