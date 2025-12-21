#include "BgfxiOSApp.h"
#import "AppDelegate.h"
#include <bgfx/bgfx.h>
#include <bgfx/platform.h>

//*
//int BgfxiOSMain()
int BgfxiOSMain( int argc, char * argv[] )
{
    NSString * appDelegateClassName;
    @autoreleasepool { //??? Do we need this with ARC???
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    // what about an app delegate???
    //constexpr const int argc = 0;
    //const char *argv[] = nullptr;
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
//*/

//void BgfxiOSApp::init( int width, int height, float scaleFactor, void *nwh, void *context, bool isPortrait )
void BgfxiOSApp::init( int width, int height, float scaleFactor, void *nwh, void *context )//, bool isPortrait )
{

}

void BgfxiOSApp::setRefreshFunc( const std::function<void()> &refreshFunc )
{

}

void BgfxiOSApp::setRefreshAtTimeFunc( const std::function<void(float)> &refreshFunc )
{

}

void BgfxiOSApp::setAutoRefreshStateFunc( const std::function<void(bool)> &autoRefreshStateFunc )
{

}
#ifdef ENABLE_CAMERA
void BgfxiOSApp::setShowImagePickerPhotoFunc( const std::function<void()> &showImagePickerFunc )
{

}

void BgfxiOSApp::setShowImagePickerCameraFunc( const std::function<void()> &showImagePickerFunc )
{

}

//void BgfxiOSApp::setShowImageCropperFunc( const std::function<void()> &showImageCropperFunc )
void BgfxiOSApp::setPickedImage( const uint8_t *data, size_t width, size_t height, size_t bytesPerPixel )
{

}
#endif   

void BgfxiOSApp::setEnableIndicatorFunc( const std::function<void( bool )> &enableIndicatorFunc )
{

}

void BgfxiOSApp::render()
{

}

void BgfxiOSApp::resize( int width, int height, float scaleFactor )
{

}

void BgfxiOSApp::update()
{

}

void BgfxiOSApp::shutdown()
{

}

bool BgfxiOSApp::enableAutoRefresh()
{

}

void BgfxiOSApp::handleKeyDown( int keyCode )
{

}

void BgfxiOSApp::handleKeyUp( int keyCode )
{

}

void BgfxiOSApp::handleMouseDown( float x, float y, int button )
{

}

void BgfxiOSApp::handleMouseUp( float x, float y, int button )
{

}

void BgfxiOSApp::handleMouseMove( float x, float y )
{

}

void BgfxiOSApp::handleMouseWheel( float x, float y, float deltaX, float deltaY )
{

}

void BgfxiOSApp::handleChangeOrientation()
{

}

void BgfxiOSApp::handleSwipe( float x, float y, int direction )
{

}

void BgfxiOSApp::handleSingleTap( float x, float y )
{

}

void BgfxiOSApp::handleDoubleTap( float x, float y )
{

}

void BgfxiOSApp::handlePan( 
    float posX, float posY,
    float transX, float transY,
    float velX, float velY,
    int numTouches 
)
{
    
}

void BgfxiOSApp::handlePinch( float x, float y, float scale )
{

}

void BgfxiOSApp::handleRotation( float x, float y, float rotation )
{

}

void BgfxiOSApp::viewDidLoad()
{

}

void BgfxiOSApp::viewWillAppear()
{

}
void BgfxiOSApp::viewWillDisappear()
{

}

void BgfxiOSApp::viewDidDisappear()
{

}

void BgfxiOSApp::viewWillTransitionToSize()
{

}

void BgfxiOSApp::viewDidLayoutSubviews()
{

}

void BgfxiOSApp::applicationDidBecomeActive()
{

}

void BgfxiOSApp::applicationWillResignActive()
{

}

void BgfxiOSApp::applicationDidEnterBackground()
{

}

void BgfxiOSApp::applicationWillEnterForeground()
{

}

void BgfxiOSApp::applicationDidFinishLaunching()
{

}

void BgfxiOSApp::didReceivememoryWarning()
{

}
