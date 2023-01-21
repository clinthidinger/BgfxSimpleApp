//
//  IBgfxWin32App.h
//  Test_Game
//
//  Created by clint hidinger on 1/2/20.
//  Copyright © 2020 me. All rights reserved.
//

#pragma once

#include <functional>
#include <memory>
#include "Win32Application.h"
#include "app/IBgfxApp.h"

class IBgfxWin32App : public IBgfxApp
{
public:
    virtual ~IBgfxWin32App() = default;
    
    virtual void init( int width, int height, float scaleFactor, void *nwh, void *context ) = 0;
    virtual void setRefeshFunc( const std::function<void()> &refreshFunc ) = 0;
    virtual void setAutoRefeshStateFunc( const std::function<void(bool)> &autoRefreshStateFunc ) = 0;
    
    virtual void render() = 0;
    virtual void resize( int width, int height, float scaleFactor ) = 0;
    virtual void update() = 0;
    virtual void shutdown() = 0;
    virtual bool enableAutoRefresh() = 0;
    
    enum class KeyModifier
    {
        ALT_DOWN   = 1 << 0,
        CTRL_DOWN  = 1 << 1,
        SHIFT_DOWN = 1 << 2,
        META_DOWN  = 1 << 3,
    };

    virtual void handleKeyDown( uint8_t key, int keyMods ) = 0;
    virtual void handleKeyUp( uint8_t key, int keyMods ) = 0;
    virtual void handleMouseDown( uint8_t button, float x, float y ) = 0;
    virtual void handleMouseUp( uint8_t button, float x, float y ) = 0;
    virtual void handleMouseDrag( uint8_t button, float x, float y ) = 0;
    virtual void handleMouseWheel( float x, float y, int delta ) = 0;

    // TODO: virtual void handleFileDrop( WindowRef win, int x, int y, const std::vector<fs::path> &aFiles );// const std::string &filePath ) = 0;

    virtual int getWidth() const = 0;
    virtual int getHeight() const = 0;
    virtual void setWidth( int width ) = 0;
    virtual void setHeight( int height ) = 0;
    virtual const wchar_t* const getTitle() const = 0;
};


#define BgfxWin32Main( MyAppType ) int WINAPI WinMain( HINSTANCE hInstance, HINSTANCE, LPSTR, int nCmdShow ) \
{ \
    return Win32Application::Run( std::move( std::unique_ptr<Win32Application::AppType>( new MyAppType() ) ), hInstance, nCmdShow ); \
}
