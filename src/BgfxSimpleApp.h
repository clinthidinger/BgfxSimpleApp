//
//  Created by clint hidinger on 1/2/20.
//  Copyright © 2020 me. All rights reserved.
//

#pragma once

#include <chrono>
#include <functional>
#include <map>
#include <memory>
#include <bgfx/platform.h>
#include <bx/file.h>
#include "app/win32/IBgfxWin32App.h"

class BgfxSimpleApp : public IBgfxWin32App
{
public:
    BgfxSimpleApp() = default;
    ~BgfxSimpleApp() override;
    void init( int width, int height, float scaleFactor, void* nwh, void* device ) override;
    void render( int width, int height, float scaleFactor ) override;
    void resize( int width, int height, float scaleFactor ) override;
    void update() override;
    void shutdown()  override;
    bool enableAutoRefresh() override;

    void setRefeshFunc( const std::function<void()>& refreshFunc ) override;
    void setAutoRefeshStateFunc( const std::function<void( bool )>& autoRefreshStateFunc ) override;

    void handleKeyDown( uint8_t key, int keyMods ) override;
    void handleKeyUp( uint8_t key, int keyMods ) override;
    void handleMouseDown( uint8_t button, float x, float y ) override;
    void handleMouseUp( uint8_t button, float x, float y ) override;
    void handleMouseDrag( uint8_t button, float x, float y ) override;
    void handleMouseWheel( float x, float y, int delta ) override;

    int getWidth() const override;
    int getHeight() const override;
    void setWidth( int width ) override;
    void setHeight( int height ) override;
    const wchar_t* const getTitle() const override;

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
