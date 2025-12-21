//
//  BasicApp.cpp
//  Test_Game
//
//  Created by clint hidinger on 1/2/20.
//  Copyright � 2020 me. All rights reserved.
//

#include "BasicApp.h"
#include <assert.h>
#include <cstring>
#include <iostream>
//#include "bx/timer.h"
#include <bgfx/bgfx.h>
#include <bgfx/platform.h>


// Note: only necessary without imgui.
// Note: this seems to be necessary to link with the necessary funcs from nanoVG fonts.
//#define STBTT_DEF extern
//#define STB_TRUETYPE_IMPLEMENTATION
//#include <stb/stb_truetype.h>

void BasicApp::init( int width, int height, float scaleFactor, void *nwh, void *device )
{
    mWidth = width;
    mHeight = height;
    assert( width != 0 && height != 0 );
    bgfx::PlatformData platformData;
    platformData.ndt = nullptr;
    platformData.nwh = nwh;
    platformData.context = device;
    platformData.backBuffer = nullptr;
    platformData.backBufferDS = nullptr;
    bgfx::setPlatformData( platformData );

    // On iOS, call renderFrame before init to set up render thread properly
    bgfx::renderFrame();

    bgfx::Init init;
    init.type = bgfx::RendererType::Metal;  // Explicitly use Metal on iOS
    init.vendorId = BGFX_PCI_ID_NONE;//args.m_pciId;
    init.resolution.width = width;
    init.resolution.height = height;
    init.resolution.reset = BGFX_RESET_VSYNC;// | BGFX_RESET_MSAA_X16;
    init.platformData = platformData;
    bgfx::init( init );
    //bgfx::reset( width, height, BGFX_RESET_MSAA_X16 );

    // Note: This is necessary for fill ops in nanovg to not overlap.
    bgfx::setViewMode( mDefaultViewId, bgfx::ViewMode::Sequential );
    
    // Enable debug text.
    //bgfx::setDebug( BGFX_DEBUG_NONE ); //  BGFX_DEBUG_TEXT
    bgfx::setDebug( BGFX_DEBUG_TEXT ); //  BGFX_DEBUG_TEXT
    //bgfx::setDebug( BGFX_DEBUG_STATS ); //  BGFX_DEBUG_TEXT

    // Set view 0 clear state.
    bgfx::setViewClear( mDefaultViewId
        , BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH
        , 0x308030ff
        , 1.0f
        , 0
    );

    mCaps = bgfx::getCaps();   
}

BasicApp::~BasicApp()
{
    //shutdown();
}

void BasicApp::render()
{
    bgfx::setViewRect( mDefaultViewId, 0, 0, uint16_t( mWidth ), uint16_t( mHeight ) );

    // This dummy draw call is here to make sure that view 0 is cleared
    bgfx::touch( mDefaultViewId );

    /*
    float ortho[16];
    // Note: Setting upper left to be origin here instead of bottom left. This
    //       match the settings of nanovg and opencv.
    bx::mtxOrtho( ortho, 0.0f, float( width ), float( height ), 0, 0.0f, 100.0f, 0.0, mCaps->homogeneousDepth );
    bgfx::setViewTransform( mDefaultViewId, nullptr, ortho );
    */

    mCurrentFrame = bgfx::frame();
}


void BasicApp::update()
{
    using namespace std::chrono;
    auto nowTime = system_clock::now();
    auto deltaUS = duration_cast<microseconds>( nowTime - mLastFrameTime ).count();
    mDeltaTime = static_cast<float>( deltaUS ) / 1000000.0f;
    mTimeSeconds += mDeltaTime;
    mLastFrameTime = nowTime;
}

void BasicApp::shutdown()
{
    std::cerr << "shutdown\n"; //??? who calls?
    bgfx::shutdown(); //!!! SHOULD be called by App hooks.
}

void BasicApp::resize( int width, int height, float scaleFactor )
{
    mWidth = width;
    mHeight = height;
    std::cerr << "resize: " << width << ", " << height << ", " << scaleFactor << "\n";
}

bool BasicApp::enableAutoRefresh()
{
    //return false;
    return true;
}

#if !defined(TARGET_OS_IPHONE) 

void BasicApp::handleKeyDown( uint16_t key, int keyMods )
{

}

void BasicApp::handleKeyUp( uint16_t key, int keyMods )
{

}

void BasicApp::handleMouseDown( uint8_t button, float x, float y )
{

}

void BasicApp::handleMouseUp( uint8_t button, float x, float y )
{

}

void BasicApp::handleMouseDrag( uint8_t button, float x, float y )
{

}

void BasicApp::handleMouseWheel( float x, float y, int delta )
{

}

void BasicApp::handleMouseMove( float x, float y )
{
    
}

#endif

#if defined(ENABLE_GESTURES) || defined(TARGET_OS_IPHONE)

void BasicApp::handleChangeOrientation()
{

}

void BasicApp::handleSwipe( float x, float y, int direction )
{

}

void BasicApp::handleSingleTap( float x, float y )
{

}

void BasicApp::handleDoubleTap( float x, float y )
{

}

void BasicApp::handlePan( float x, float y, float translationX, float translationY, float velocityX, float velocityY, int numTouches )
{

}

void BasicApp::handlePinch( float x, float y, float scale )
{

}

void BasicApp::handleRotation( float x, float y, float rotation )
{

}

// iOS-specific input handlers
void BasicApp::handleKeyDown( int keyCode )
{

}

void BasicApp::handleKeyUp( int keyCode )
{

}

void BasicApp::handleMouseDown( float x, float y, int button )
{

}

void BasicApp::handleMouseUp( float x, float y, int button )
{

}

void BasicApp::handleMouseMove( float x, float y )
{

}

void BasicApp::handleMouseWheel( float x, float y, float deltaX, float deltaY )
{

}

// iOS lifecycle methods
void BasicApp::viewDidLoad()
{

}

void BasicApp::viewWillAppear()
{

}

void BasicApp::viewWillDisappear()
{

}

void BasicApp::viewDidDisappear()
{

}

void BasicApp::viewWillTransitionToSize()
{

}

void BasicApp::viewDidLayoutSubviews()
{

}

void BasicApp::applicationDidBecomeActive()
{

}

void BasicApp::applicationWillResignActive()
{

}

void BasicApp::applicationDidEnterBackground()
{

}

void BasicApp::applicationWillEnterForeground()
{

}

void BasicApp::applicationDidFinishLaunching()
{

}

void BasicApp::didReceivememoryWarning()
{

}

#endif

#if !defined(TARGET_OS_IPHONE)

int BasicApp::getWidth() const
{
    return mWidth;
}

int BasicApp::getHeight() const
{
    return mHeight;
}

void BasicApp::setWidth( int width )
{
    mWidth = width;
}

void BasicApp::setHeight( int height )
{
    mHeight = height;
}

const char* const BasicApp::getTitle() const
{
    return "BGFX Simple App";
}

#endif

void BasicApp::setRefreshAtTimeFunc( const std::function<void(float)> &refreshFunc )
{

}

void BasicApp::setRefreshFunc( const std::function<void()>& refreshFunc )
{
    mRefreshFunc = refreshFunc;
}

void BasicApp::setAutoRefreshStateFunc( const std::function<void( bool )>& autoRefreshStateFunc )
{
    mAutoRefreshStateFunc = autoRefreshStateFunc;
}

void BasicApp::setEnableIndicatorFunc( const std::function<void( bool )> &enableIndicatorFunc )
{

}

#ifdef __APPLE__
//
//void BasicApp::didFinishLaunching()
//{
//    
//}
//
//void BasicApp::willTerminate()
//{
//    
//}
//
//void BasicApp::didBecomeActive()
//{
//    
//}
//
//void BasicApp::willResignActive()
//{
//    
//}

#endif


#ifdef _WIN32
BgfxWin32Main( BasicApp )
#endif

// Note: SwiftUI handles main entry point on iOS, so don't use BgfxMain macro
#if !defined(TARGET_OS_IPHONE)
BgfxMain( BasicApp )
#endif