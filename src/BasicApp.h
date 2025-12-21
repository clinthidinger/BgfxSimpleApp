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
#define BGFX_BASE_APP_DEFINED 1
#endif
#ifdef __APPLE__
#include <TargetConditionals.h>
    #if TARGET_OS_IPHONE
        #include "app/ios/IBgfxiOSApp.h"
        #define BGFX_BASE_APP IBgfxiOSApp
        #define BGFX_BASE_APP_DEFINED 1
    #elif TARGET_OS_MAC
        #include "app/osx/IBgfxOSXApp.h"
        #define BGFX_BASE_APP IBgfxOSXApp
        #define BGFX_BASE_APP_DEFINED 1
    #endif
#endif

#if BGFX_BASE_APP_DEFINED
class BasicApp : public BGFX_BASE_APP
#define OVERRIDE override
#else
class BasicApp
#define OVERRIDE
#endif
{
public:
    ~BasicApp() OVERRIDE;
    //  virtual void init( int width, int height, float scaleFactor, void *nwh, void *context, bool isPortrait ) = 0;
    void init( int width, int height, float scaleFactor, void* nwh, void* device ) OVERRIDE;
    void render() OVERRIDE;
    void resize( int width, int height, float scaleFactor ) OVERRIDE;
    void update() OVERRIDE;
    void shutdown()  OVERRIDE;
    bool enableAutoRefresh() OVERRIDE;

    void setRefreshFunc( const std::function<void()>& refreshFunc ) OVERRIDE;
    void setRefreshAtTimeFunc( const std::function<void(float)> &refreshFunc ) OVERRIDE;
    void setAutoRefreshStateFunc( const std::function<void( bool )>& autoRefreshStateFunc ) OVERRIDE;
    void setEnableIndicatorFunc( const std::function<void( bool )> &enableIndicatorFunc ) OVERRIDE;

#if !defined(TARGET_OS_IPHONE) // WHat if you they hoooked up a keyboard and mouse to iPad???
    void handleKeyDown( uint16_t key, int keyMods ) OVERRIDE;
    void handleKeyUp( uint16_t key, int keyMods ) OVERRIDE;
    void handleMouseDown( uint8_t button, float x, float y ) OVERRIDE;
    void handleMouseUp( uint8_t button, float x, float y ) OVERRIDE;
    void handleMouseDrag( uint8_t button, float x, float y ) OVERRIDE;
    void handleMouseWheel( float x, float y, int delta ) OVERRIDE;
    void handleMouseMove( float x, float y ) OVERRIDE;

    int getWidth() const OVERRIDE;
    int getHeight() const OVERRIDE;
    void setWidth( int width ) OVERRIDE;
    void setHeight( int height ) OVERRIDE;
    const char* const getTitle() const OVERRIDE;
#endif

#ifdef __APPLE__

#if defined(ENABLE_GESTURES) || defined(TARGET_OS_IPHONE)
    void handleChangeOrientation() OVERRIDE;
    void handleSwipe( float x, float y, int direction ) OVERRIDE;
    void handleSingleTap( float x, float y ) OVERRIDE;
    void handleDoubleTap( float x, float y ) OVERRIDE;
    void handlePan( float x, float y, float translationX, float translationY, float velocityX, float velocityY, int numTouches ) OVERRIDE;
    void handlePinch( float x, float y, float scale ) OVERRIDE;
    void handleRotation( float x, float y, float rotation ) OVERRIDE;

    // iOS-specific input handlers (different signatures than desktop)
    void handleKeyDown( int keyCode ) OVERRIDE;
    void handleKeyUp( int keyCode ) OVERRIDE;
    void handleMouseDown( float x, float y, int button ) OVERRIDE;
    void handleMouseUp( float x, float y, int button ) OVERRIDE;
    void handleMouseMove( float x, float y ) OVERRIDE;
    void handleMouseWheel( float x, float y, float deltaX, float deltaY ) OVERRIDE;

    // iOS lifecycle methods
    void viewDidLoad() OVERRIDE;
    void viewWillAppear() OVERRIDE;
    void viewWillDisappear() OVERRIDE;
    void viewDidDisappear() OVERRIDE;
    void viewWillTransitionToSize() OVERRIDE;
    void viewDidLayoutSubviews() OVERRIDE;
    void applicationDidBecomeActive() OVERRIDE;
    void applicationWillResignActive() OVERRIDE;
    void applicationDidEnterBackground() OVERRIDE;
    void applicationWillEnterForeground() OVERRIDE;
    void applicationDidFinishLaunching() OVERRIDE;
    void didReceivememoryWarning() OVERRIDE;
#endif
    
//    void didFinishLaunching() OVERRIDE;
//    //!!!void willTerminate() OVERRIDE;
//    void willResignActive() OVERRIDE;
//    void didBecomeActive() OVERRIDE;
//    void didEnterBackground() OVERRIDE;
//    void willEnterForeground() OVERRIDE;
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
