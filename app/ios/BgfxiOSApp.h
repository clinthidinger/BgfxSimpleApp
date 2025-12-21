#pragma once

#include "IBgfxiOSApp.h"

class BgfxiOSApp : public IBgfxiOSApp
{
public:
    
    void init( int width, int height, float scaleFactor, void *nwh, void *context, bool isPortrait ) override;
    void setRefreshFunc( const std::function<void()> &refreshFunc ) override;
    void setRefreshAtTimeFunc( const std::function<void(float)> &refreshFunc ) override;
    void setAutoRefreshStateFunc( const std::function<void(bool)> &autoRefreshStateFunc ) override;
#ifdef ENABLE_CAMERA
    void setShowImagePickerPhotoFunc( const std::function<void()> &showImagePickerFunc ) override;
    void setShowImagePickerCameraFunc( const std::function<void()> &showImagePickerFunc ) override;
    //void setShowImageCropperFunc( const std::function<void()> &showImageCropperFunc ) override;
    void setPickedImage( const uint8_t *data, size_t width, size_t height, size_t bytesPerPixel ) override;
 #endif   

    void setEnableIndicatorFunc( const std::function<void( bool )> &enableIndicatorFunc ) override;
    
    void render() override;
    void resize( int width, int height, float scaleFactor ) override;
    void update() override;
    void shutdown() override;
    bool enableAutoRefresh() override;
    
    void handleChangeOrientation() override;
    void handleSwipe( float x, float y, int direction ) override;
    void handleSingleTap( float x, float y ) override;
    void handleDoubleTap( float x, float y ) override;
    void handlePan( float posX, float posY,
                            float transX, float transY,
                            float velX, float velY,
                            int numTouches ) override;
    void handlePinch( float x, float y, float scale ) override;
    void handleRotation( float x, float y, float rotation ) override;
    
    void viewDidLoad() override;
    void viewWillAppear() override;
    void viewWillDisappear() override;
    void viewDidDisappear() override;
    void viewWillTransitionToSize() override;
    void viewDidLayoutSubviews() override;
    void applicationDidBecomeActive() override;
    void applicationWillResignActive() override;
    void applicationDidEnterBackground() override;
    void applicationWillEnterForeground() override;
    void applicationDidFinishLaunching() override;
    void didReceivememoryWarning() override;
};


int BgfxiOSMain(); 

#define BgfxMain( MyAppType ) int main( int argc, const char *argv[] ) \
{ \
    BgfxiOSAppLauncher::instance().setApp( new MyAppType() ); \
    return  BgfxiOSMain(argc, argv);\
}