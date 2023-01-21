//
//  BgfxSimpleApp.cpp
//  Test_Game
//
//  Created by clint hidinger on 1/2/20.
//  Copyright © 2020 me. All rights reserved.
//

#include "BGfxSimpleApp.h"
#include <assert.h>
#include <cstring>
#include <iostream>
#include "bx/timer.h"


// Note: only necessary without imgui.
// Note: this seems to be necessary to link with the necessary funcs from nanoVG fonts.
//#define STBTT_DEF extern
//#define STB_TRUETYPE_IMPLEMENTATION
//#include <stb/stb_truetype.h>

void BgfxSimpleApp::init( int width, int height, float scaleFactor, void *nwh, void *device )
{
    assert( width != 0 && height != 0 );
    bgfx::PlatformData platformData;
    platformData.ndt = nullptr;
    platformData.nwh = nwh;
    platformData.context = device;
    platformData.backBuffer = nullptr;
    platformData.backBufferDS = nullptr;
    bgfx::setPlatformData( platformData );

    //bgfx::renderFrame();

    bgfx::Init init;
    init.type = bgfx::RendererType::Enum::Count;//bgfx::RendererType::Metal;
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
        , 0x303030ff
        , 1.0f
        , 0
    );

    mCaps = bgfx::getCaps();
   
}

BgfxSimpleApp::~BgfxSimpleApp()
{
    shutdown();
}

void BgfxSimpleApp::render( int width, int height, float scaleFactor )
{
    bgfx::setViewRect( mDefaultViewId, 0, 0, uint16_t( width ), uint16_t( height ) );

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


void BgfxSimpleApp::update()
{
    using namespace std::chrono;
    auto nowTime = system_clock::now();
    auto deltaUS = duration_cast<microseconds>( nowTime - mLastFrameTime ).count();
    mDeltaTime = static_cast<float>( deltaUS ) / 1000000.0f;
    mTimeSeconds += mDeltaTime;
    mLastFrameTime = nowTime;
}

void BgfxSimpleApp::shutdown()
{
    std::cerr << "shutdown\n"; //??? who calls?
    bgfx::shutdown();
}

void BgfxSimpleApp::resize( int width, int height, float scaleFactor )
{
    std::cerr << "resize: " << width << ", " << height << ", " << scaleFactor << "\n";
}

bool BgfxSimpleApp::enableAutoRefresh()
{
    //return false;
    return true;
}

void BgfxSimpleApp::handleKeyDown( uint8_t key, int keyMods )
{

}

void BgfxSimpleApp::handleKeyUp( uint8_t key, int keyMods )
{

}

void BgfxSimpleApp::handleMouseDown( uint8_t button, float x, float y )
{

}

void BgfxSimpleApp::handleMouseUp( uint8_t button, float x, float y )
{

}

void BgfxSimpleApp::handleMouseDrag( uint8_t button, float x, float y )
{

}

void BgfxSimpleApp::handleMouseWheel( float x, float y, int delta )
{

}


int BgfxSimpleApp::getWidth() const
{
    return mWidth;
}

int BgfxSimpleApp::getHeight() const
{
    return mHeight;
}

void BgfxSimpleApp::setWidth( int width )
{
    mWidth = width;
}

void BgfxSimpleApp::setHeight( int height )
{
    mHeight = height;
}

void BgfxSimpleApp::setRefeshFunc( const std::function<void()>& refreshFunc )
{
    mRefreshFunc = refreshFunc;
}

void BgfxSimpleApp::setAutoRefeshStateFunc( const std::function<void( bool )>& autoRefreshStateFunc )
{
    mAutoRefreshStateFunc = autoRefreshStateFunc;
}

const wchar_t* const BgfxSimpleApp::getTitle() const
{
    return L"BGFX Simple App";
}

BgfxWin32Main( BgfxSimpleApp )
