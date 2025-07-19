//
//  Created by clint hidinger on 1/2/20.
//  Copyright � 2020 me. All rights reserved.
//

#pragma once

#include <chrono>
#include <functional>
#include <map>
#include <memory>
#include <bgfx/platform.h>
#include <bx/file.h>
#ifdef _WIN32
#include "app/win32/IBgfxWin32App.h"
#define IBGFX_BASE_APP IBgfxWin32App
#endif
#ifdef __APPLE__
#include <TargetConditionals.h>
    #if TARGET_OS_IPHONE
        #include "app/ios/IBgfxiOSApp.h"
        #define IBGFX_BASE_APP IBgfxiOSApp
    #elif TARGET_OS_MAC
        #include "app/osx/IBgfxOSXApp.h"
        #define IBGFX_BASE_APP IBgfxOSXApp
    #endif
#endif

class BgfxSimpleApp : public IBGFX_BASE_APP
{
public:
    ~BgfxSimpleApp() override;
    void init( int width, int height, float scaleFactor, void* nwh, void* device ) override;
    void render() override;
    void resize( int width, int height, float scaleFactor ) override;
    void update() override;
    void shutdown()  override;
    bool enableAutoRefresh() override;

    void setRefreshFunc( const std::function<void()>& refreshFunc ) override;
    void setAutoRefreshStateFunc( const std::function<void( bool )>& autoRefreshStateFunc ) override;

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

#ifdef __APPLE__
    void didFinishLaunching() override;
    void willTerminate() override;
    void didBecomeActive() override;
    void willResignActive() override;
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
