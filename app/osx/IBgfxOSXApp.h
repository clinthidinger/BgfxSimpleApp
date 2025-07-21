//
//  IBgfxOSXApp.h
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
    enum class KeyModifier
    {
        ALT_DOWN   = 1 << 0,
        CTRL_DOWN  = 1 << 1,
        SHIFT_DOWN = 1 << 2,
        META_DOWN  = 1 << 3,
    };

    virtual ~IBgfxOSXApp() = default;
    
    virtual void init( int width, int height, float scaleFactor, void *nwh, void *context ) = 0;
    virtual void setRefreshFunc( const std::function<void()> &refreshFunc ) = 0;
    virtual void setAutoRefreshStateFunc( const std::function<void(bool)> &autoRefreshStateFunc ) = 0;
    
    virtual void render() = 0;
    virtual void resize( int width, int height, float scaleFactor ) = 0;
    virtual void update() = 0;
    virtual void shutdown() = 0;
    virtual bool enableAutoRefresh() = 0;
    
    virtual void handleKeyDown( uint16_t key, int keyMods ) = 0;
    virtual void handleKeyUp( uint16_t key, int keyMods ) = 0;
    virtual void handleMouseDown( uint8_t button, float x, float y ) = 0;
    virtual void handleMouseUp( uint8_t button, float x, float y ) = 0;
    virtual void handleMouseDrag( uint8_t button, float x, float y ) = 0;
    virtual void handleMouseWheel( float x, float y, int delta ) = 0;
    virtual void handleMouseMove( float x, float y ) = 0;
    
    // Gesture handling methods for trackpad support
#ifdef ENABLE_GESTURES
    virtual void handleSingleTap( float x, float y ) = 0;
    virtual void handleDoubleTap( float x, float y ) = 0;
    virtual void handlePan( float x, float y, float translationX, float translationY, float velocityX, float velocityY, int numTouches ) = 0;
    virtual void handlePinch( int type, float x, float y, float scale ) = 0;
    virtual void handleRotation( float x, float y, float rotation ) = 0;
#endif
    
    virtual int getWidth() const = 0;
    virtual int getHeight() const = 0;
    virtual void setWidth( int width ) = 0;
    virtual void setHeight( int height ) = 0;    
    virtual const char* const getTitle() const = 0;
    
    virtual void didFinishLaunching() = 0;
    virtual void willTerminate() = 0;
    virtual void didBecomeActive() = 0;
    virtual void willResignActive() = 0;
};
