//
//  Created by clint hidinger on 1/2/20.
//  Copyright � 2020 me. All rights reserved.
//

#pragma once

#include <chrono>
#include <functional>
#include <map>
#include <memory>
//#include <bgfx/platform.h>
//#include <bx/file.h>
#include <bgfx/bgfx.h>
#ifdef _WIN32
#include "app/win32/IBgfxWin32App.h"
#define BGFX_BASE_APP IBgfxWin32App
#endif
#ifdef __APPLE__
#include <TargetConditionals.h>
    #if TARGET_OS_IPHONE
        #include "app/ios/BgfxiOSApp.h"
        #define BGFX_BASE_APP BgfxiOSApp
    #elif TARGET_OS_MAC
        #include "app/osx/IBgfxOSXApp.h"
        #define BGFX_BASE_APP IBgfxOSXApp
    #endif
#endif

class BasicApp : public BGFX_BASE_APP
{
public:
    ~BasicApp() override;
    //  virtual void init( int width, int height, float scaleFactor, void *nwh, void *context, bool isPortrait ) = 0;
    void init( int width, int height, float scaleFactor, void* nwh, void* device ) override;
    void render() override;
    void resize( int width, int height, float scaleFactor ) override;
    void update() override;
    void shutdown()  override;
    bool enableAutoRefresh() override;

    void setRefreshFunc( const std::function<void()>& refreshFunc ) override;
    void setRefreshAtTimeFunc( const std::function<void(float)> &refreshFunc ) override;
    void setAutoRefreshStateFunc( const std::function<void( bool )>& autoRefreshStateFunc ) override;
    //void setRefreshAtTimeFunc( const std::function<void(float)> &refreshFunc ) override;

#if !defined(TARGET_OS_IPHONE) // WHat if you they hoooked up a keyboard and mouse to iPad???
    void handleKeyDown( uint16_t key, int keyMods ) override;
    void handleKeyUp( uint16_t key, int keyMods ) override;
    void handleMouseDown( uint8_t button, float x, float y ) override;
    void handleMouseUp( uint8_t button, float x, float y ) override;
    void handleMouseDrag( uint8_t button, float x, float y ) override;
    void handleMouseWheel( float x, float y, int delta ) override;
    void handleMouseMove( float x, float y ) override;

    int getWidth() const override;
    int getHeight() const override;
    void setWidth( int width ) override;
    void setHeight( int height ) override;
    const char* const getTitle() const override;
#endif

#ifdef __APPLE__

#if defined(ENABLE_GESTURES) || defined(TARGET_OS_IPHONE)
    //void handleSwipe( float x, float y, int direction ) override;
    void handleSingleTap( float x, float y ) override;
    void handleDoubleTap( float x, float y ) override;
    void handlePan( float x, float y, float translationX, float translationY, float velocityX, float velocityY, int numTouches ) override;
    // int type ???
    //void handlePinch( float x, float y, float scale ) override;
    //void handleRotation( float x, float y, float rotation ) override;
#endif
    
//    void didFinishLaunching() override;
//    //!!!void willTerminate() override;
//    void willResignActive() override;
//    void didBecomeActive() override;
//    void didEnterBackground() override;
//    void willEnterForeground() override;
#endif
    
private:
    std::function<void()> mRefreshFunc;
    std::function<void( bool )> mAutoRefreshStateFunc;
    const bgfx::Caps *mCaps{ nullptr };
    int64_t m_timeOffset{ 0 };
    const bgfx::ViewId mDefaultViewId{ 0 }; // Default render pass.
    std::chrono::system_clock::time_point mLastFrameTime;
    float mDeltaTime{ 0.0f };
    float mTimeSeconds{ 0.0f };
    uint64_t mCurrentFrame{ 0 };
    int mWidth{ 1200 };
    int mHeight{ 800 };
};
