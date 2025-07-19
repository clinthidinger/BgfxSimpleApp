//
//  IBgfxiOSApp.h
//  ArtHUD
//
//  Created by clint hidinger on 1/2/20.
//  Copyright © 2020 me. All rights reserved.
//

#pragma once

#include <functional>
#include "../IBgfxApp.h"

class IBgfxOSXApp : public IBgfxApp
{
public:
    enum class GestureFlag
    {
        Swipe = 1 << 0,
        SingleTap = 1 << 1,
        DoubleTap = 1 << 2,
        Pan = 1 << 3,
        Pinch = 1 << 4,
        Rotate = 1 << 5,
        COUNT
    };
    virtual ~IBgfxOSXApp() = default;
    
    virtual void init( int width, int height, float scaleFactor, void *nwh, void *context, bool isPortrait ) = 0;
    virtual void setRefeshFunc( const std::function<void()> &refreshFunc ) = 0;
    virtual void setRefeshAtTimeFunc( const std::function<void(float)> &refreshFunc ) = 0;
    virtual void setAutoRefeshStateFunc( const std::function<void(bool)> &autoRefreshStateFunc ) = 0;
    virtual void setShowImagePickerPhotoFunc( const std::function<void()> &showImagePickerFunc ) = 0;
    virtual void setShowImagePickerCameraFunc( const std::function<void()> &showImagePickerFunc ) = 0;
    //virtual void setShowImageCropperFunc( const std::function<void()> &showImageCropperFunc ) = 0;
    virtual void setPickedImage( const uint8_t *data, size_t width, size_t height, size_t bytesPerPixel ) = 0;
    
    virtual void setEnableIndicatorFunc( const std::function<void( bool )> &enableIndicatorFunc ) = 0;
    
    virtual void render( int width, int height, float scaleFactor, bool isPortrait ) = 0;
    virtual void resize( int width, int height, float scaleFactor ) = 0;
    virtual void update() = 0;
    virtual void shutdown() = 0;
    virtual bool enableAutoRefresh() = 0;
    
    virtual void handleSwipe( float x, float y, int direction ) = 0;
    virtual void handleSingleTap( float x, float y ) = 0;
    virtual void handleDoubleTap( float x, float y ) = 0;
    virtual void handlePan( float posX, float posY,
                            float transX, float transY,
                            float velX, float velY,
                            int numTouches ) = 0;
    virtual void handlePinch( float x, float y, float scale ) = 0;
    virtual void handleRotation( float x, float y, float rotation ) = 0;
    
    virtual void didFinishLaunching() = 0;
    virtual void willResignActive() = 0;
    virtual void didEnterBackground() = 0;
    virtual void willEnterForeground() = 0;
    virtual void didBecomeActive() = 0;
};
