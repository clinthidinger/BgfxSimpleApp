#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <Windows.h>
#include <shellapi.h>
#include "Win32Application.h"
#include <assert.h>
#include <iostream>
#include <memory>
//#ifndef BGFX_CONFIG_MULTITHREADED
//#define BGFX_CONFIG_MULTITHREADED 1
//#endif
#include <bgfx/bgfx.h>
#include <bgfx/platform.h>
#include <bimg/bimg.h>
#include <bx/file.h>
#include <bx/math.h>
#include <bx/pixelformat.h>
#include <bx/timer.h>

#ifdef ENABLE_GESTURES
#include <winuser.h>
#include <tpcshrd.h>
#pragma comment(lib, "user32.lib")
#endif

HWND Win32Application::mHwnd = nullptr;
int Win32Application::mFrameNum = 0;
std::unique_ptr<Win32Application::AppType> Win32Application::mApp;
int Win32Application::mMouseButtonState[3] = { 0, 0, 0 };

int Win32Application::Run( std::unique_ptr<AppType> app, HINSTANCE hInstance, int nCmdShow )
{
    mApp = std::move( app );
    // Parse the command line parameters
    int argc = 0;
    LPWSTR* argv = CommandLineToArgvW( GetCommandLineW(), &argc );
    //mApp->parseCommandLineArgs( argv, argc );
    LocalFree( argv );

    // Initialize the window class.
    WNDCLASSEX windowClass = { 0 };
    windowClass.cbSize = sizeof( WNDCLASSEX );
    windowClass.style = CS_HREDRAW | CS_VREDRAW;
    windowClass.lpfnWndProc = WindowProc;
    windowClass.hInstance = hInstance;
    windowClass.hCursor = LoadCursor( NULL, IDC_ARROW );
    windowClass.lpszClassName = L"Win32 App";
    RegisterClassEx( &windowClass );

    RECT windowRect = { 
        0,
        0,
        static_cast< LONG >( mApp->getWidth() ),
        static_cast< LONG >( mApp->getHeight() )
    };
    AdjustWindowRect( &windowRect, WS_OVERLAPPEDWINDOW, FALSE );

    // Create the window and store a handle to it.
    mHwnd = CreateWindow(
        windowClass.lpszClassName,
        mApp->getTitle(),
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT,
        CW_USEDEFAULT,
        windowRect.right - windowRect.left,
        windowRect.bottom - windowRect.top,
        nullptr,        // We have no parent window.
        nullptr,        // We aren't using menus.
        hInstance,
        mApp.get() );

    // Enable file drop support
    DragAcceptFiles( mHwnd, TRUE );

#ifdef ENABLE_GESTURES
    // Enable touch input for gesture support
    RegisterTouchWindow( mHwnd, 0 );
#endif

    ShowWindow( mHwnd, nCmdShow );

    // Main sample loop.
    MSG msg = {};
    while ( msg.message != WM_QUIT )
    {
        // Process any messages in the queue.
        if ( PeekMessage( &msg, NULL, 0, 0, PM_REMOVE ) )
        {
            TranslateMessage( &msg );
            DispatchMessage( &msg );
        }
    }
    
    // Return this part of the WM_QUIT message to Windows.
    return static_cast< char >( msg.wParam );
}

// Main message handler for the sample.
LRESULT CALLBACK Win32Application::WindowProc( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam )
{
    switch ( message )
    {
        case WM_CREATE:
        {
            // Save the DXSample* passed in to CreateWindow.
            LPCREATESTRUCT pCreateStruct = reinterpret_cast< LPCREATESTRUCT >( lParam );
            SetWindowLongPtr( hWnd, GWLP_USERDATA, reinterpret_cast< LONG_PTR >( pCreateStruct->lpCreateParams ) );

            RECT rect;
            GetClientRect( hWnd, &rect );
            auto const width = rect.right - rect.left;
            auto const height = rect.bottom - rect.top;
            //initBgfx( hWnd );
            mApp->setWidth( width );
            mApp->setHeight( height );
            mApp->init( width, height, 1.0f, hWnd, nullptr );
            break;
        }
        case WM_KEYDOWN:
        case WM_SYSKEYDOWN:
        {
            mApp->handleKeyDown( static_cast< uint8_t >(wParam), GetKeyModifiers() );
            break;
        }
        case WM_KEYUP:
        case WM_SYSKEYUP:
        {
            mApp->handleKeyUp( static_cast< uint8_t >(wParam), GetKeyModifiers() );
            break;
        }
        case WM_PAINT:
        {
            // Note: If BeginPaint/EndPaint is not called, the WM_PAINT message will be sent again.
            //       Alternatively, could use ValidateRect();
            //PAINTSTRUCT ps;
            //HDC hdc = BeginPaint( hWnd, &ps );
             // TODO: Add any drawing code that uses hdc here...
            //bgfxUpdate();
            mApp->update();
            mApp->render();
            //bgfx::renderFrame();
            //EndPaint( hWnd, &ps );
            if ( !mApp->enableAutoRefresh() )
            {
                if ( mFrameNum % 2 == 0 )
                {
                    ValidateRect( hWnd, nullptr );
                }
            }
            //InvalidateRect(hWnd, nullptr, true);
            break;
        }
        case WM_SIZE:
        {
            RECT rect;
            GetClientRect( hWnd, &rect );
            // window or client size???
            auto const width = LOWORD( lParam );
            auto const height = HIWORD( lParam );
            mApp->resize( width, height, 1.0f );
            // Note: reset() is necessary to reset the backbuffer: https://github.com/bkaradzic/bgfx/issues/1203
            bgfx::reset( width, height ); //, BGFX_RESET_FLUSH_AFTER_RENDER );
            bgfx::frame();
            InvalidateRect( hWnd, nullptr, true );
            break;
        }
        case WM_CLOSE:
        {
            ::DestroyWindow( hWnd ); // triggers WM_DESTROY
            break;
        }
        case WM_DESTROY:
        {
            if (mApp) {
                mApp->shutdown();
                mApp.reset();
            }
            PostQuitMessage( 0 ); // this triggers the WM_QUIT to break the loop
            break;
        }
        case WM_LBUTTONDOWN:
        {
            mApp->handleMouseDown( 0, static_cast<float>(static_cast<short>(LOWORD( lParam ))), static_cast<float>(static_cast<short>(HIWORD( lParam ))) );
            mMouseButtonState[0] = 1;
            break;
        }
        case WM_LBUTTONUP:
        {
            mApp->handleMouseUp( 0, static_cast<float>(static_cast<short>(LOWORD( lParam ))), static_cast<float>(static_cast<short>(HIWORD( lParam ))) );
            mMouseButtonState[0] = 0;
            break;
        }
        case WM_RBUTTONDOWN:
        {
            mApp->handleMouseDown( 1, static_cast<float>(static_cast<short>(LOWORD( lParam ))), static_cast<float>(static_cast<short>(HIWORD( lParam ))) );
            mMouseButtonState[1] = 1;
            break;
        }
        case WM_RBUTTONUP:
        {
            mApp->handleMouseUp( 1, static_cast<float>(static_cast<short>(LOWORD( lParam ))), static_cast<float>(static_cast<short>(HIWORD( lParam ))) );
            mMouseButtonState[1] = 0;
            break;
        }
        case WM_MBUTTONDOWN:
        {
            mApp->handleMouseDown( 2, static_cast<float>(static_cast<short>(LOWORD( lParam ))), static_cast<float>(static_cast<short>(HIWORD( lParam ))) );
            mMouseButtonState[2] = 1;
            break;
        }
        case WM_MBUTTONUP:
        {
            mApp->handleMouseUp( 2, static_cast<float>(static_cast<short>(LOWORD( lParam ))), static_cast<float>(static_cast<short>(HIWORD( lParam ))) );
            mMouseButtonState[2] = 0;
            break;
        }
        case WM_MOUSEMOVE:
        {
            if( !IsIconic( hWnd ) ) // Check minimized
            {
                int mouseButton = -1;
                for( int btn = 0; btn < 3; ++btn )
                {
                    if( mMouseButtonState[btn] )
                    {
                        mouseButton = btn;
                        break;
                    }
                }
                if( mouseButton != -1 )
                {
                    mApp->handleMouseDrag( mouseButton, static_cast<float>(static_cast<short>(LOWORD( lParam ))), static_cast<float>(static_cast<short>(HIWORD( lParam ))) );
                }
                else
                {
                    mApp->handleMouseMove( static_cast<float>(static_cast<short>(LOWORD( lParam ))), static_cast<float>(static_cast<short>(HIWORD( lParam ))) );
                }
            }
            break;
        }
        case WM_MOUSEWHEEL:
        {
            if( !IsIconic( hWnd ) ) // Check minimized
            {
                auto fwKeys = GET_KEYSTATE_WPARAM( wParam );
                //GET_X_LPARAM( lParam );
                mApp->handleMouseWheel( static_cast<float>(static_cast<short>(LOWORD( lParam ))),
                                        static_cast<float>(static_cast<short>(HIWORD( lParam ))),
                                        static_cast<int>( GET_WHEEL_DELTA_WPARAM( wParam ) / static_cast<float>( WHEEL_DELTA ) ) );
            }
            break;
        }
        case WM_DROPFILES:
        {
            HDROP hDrop = reinterpret_cast<HDROP>( wParam );
            POINT pt;
            DragQueryPoint( hDrop, &pt );
            
            UINT fileCount = DragQueryFileW( hDrop, 0xFFFFFFFF, nullptr, 0 );
            std::vector<std::string> filePaths;
            filePaths.reserve( fileCount );
            
            for ( UINT i = 0; i < fileCount; ++i )
            {
                UINT pathLength = DragQueryFileW( hDrop, i, nullptr, 0 );
                std::vector<WCHAR> widePath( pathLength + 1 );
                DragQueryFileW( hDrop, i, widePath.data(), pathLength + 1 );
                
                // Convert from wide to UTF-8
                int utf8Length = WideCharToMultiByte( CP_UTF8, 0, widePath.data(), -1, nullptr, 0, nullptr, nullptr );
                std::string utf8Path( utf8Length - 1, '\0' );
                WideCharToMultiByte( CP_UTF8, 0, widePath.data(), -1, utf8Path.data(), utf8Length, nullptr, nullptr );
                
                filePaths.push_back( std::move( utf8Path ) );
            }
            
            DragFinish( hDrop );
            
            if ( mApp && !filePaths.empty() )
            {
                mApp->handleFileDrop( static_cast<float>( pt.x ), static_cast<float>( pt.y ), filePaths );
            }
            break;
        }
#ifdef ENABLE_GESTURES
        case WM_TOUCH:
        {
            UINT inputCount = LOWORD( wParam );
            std::vector<TOUCHINPUT> inputs( inputCount );
            
            if ( GetTouchInputInfo( reinterpret_cast<HTOUCHINPUT>( lParam ), inputCount, inputs.data(), sizeof( TOUCHINPUT ) ) )
            {
                for ( const auto& input : inputs )
                {
                    POINT pt = { TOUCH_COORD_TO_PIXEL( input.x ), TOUCH_COORD_TO_PIXEL( input.y ) };
                    ScreenToClient( hWnd, &pt );
                    
                    if ( input.dwFlags & TOUCHEVENTF_DOWN )
                    {
                        // Handle touch down - could be start of gesture
                        if ( mApp )
                        {
                            mApp->handleSingleTap( static_cast<float>( pt.x ), static_cast<float>( pt.y ) );
                        }
                    }
                    else if ( input.dwFlags & TOUCHEVENTF_MOVE )
                    {
                        // Handle touch move - could be pan gesture
                        // Note: For proper gesture recognition, we'd need to track touch state
                        // This is a simplified implementation
                    }
                    else if ( input.dwFlags & TOUCHEVENTF_UP )
                    {
                        // Handle touch up - end of gesture
                    }
                }
                
                CloseTouchInputHandle( reinterpret_cast<HTOUCHINPUT>( lParam ) );
            }
            break;
        }
        case WM_GESTURE:
        {
            GESTUREINFO gi;
            gi.cbSize = sizeof( GESTUREINFO );
            
            if ( GetGestureInfo( reinterpret_cast<HGESTUREINFO>( lParam ), &gi ) )
            {
                POINT pt = { gi.ptsLocation.x, gi.ptsLocation.y };
                ScreenToClient( hWnd, &pt );
                
                switch ( gi.dwID )
                {
                    case GID_ZOOM:
                        if ( mApp )
                        {
                            // Convert zoom factor to scale
                            float scale = static_cast<float>( gi.ullArguments ) / 65536.0f;
                            mApp->handlePinch( 0, static_cast<float>( pt.x ), static_cast<float>( pt.y ), scale );
                        }
                        break;
                        
                    case GID_PAN:
                        if ( mApp )
                        {
                            // Pan gesture - translation is in gi.ptsLocation relative to start
                            mApp->handlePan( static_cast<float>( pt.x ), static_cast<float>( pt.y ), 
                                           static_cast<float>( gi.ptsLocation.x ), static_cast<float>( gi.ptsLocation.y ),
                                           0.0f, 0.0f, 1 ); // velocity = 0, numTouches = 1
                        }
                        break;
                        
                    case GID_ROTATE:
                        if ( mApp )
                        {
                            // Rotation angle in radians
                            float rotation = static_cast<float>( gi.ullArguments ) * 3.14159f / 32768.0f;
                            mApp->handleRotation( static_cast<float>( pt.x ), static_cast<float>( pt.y ), rotation );
                        }
                        break;
                        
                    case GID_TWOFINGERTAP:
                        if ( mApp )
                        {
                            mApp->handleDoubleTap( static_cast<float>( pt.x ), static_cast<float>( pt.y ) );
                        }
                        break;
                }
                
                CloseGestureInfoHandle( reinterpret_cast<HGESTUREINFO>( lParam ) );
            }
            break;
        }
#endif
        default:
        {
            return DefWindowProc( hWnd, message, wParam, lParam );
        }
    }// end switch

    return 0;
}

int Win32Application::GetKeyModifiers()
{
    int result = 0;
    if( ::GetKeyState( VK_CONTROL ) & 0x8000 ) result |= static_cast<int>( IBgfxWin32App::KeyModifier::CTRL_DOWN );
    if( ::GetKeyState( VK_SHIFT ) & 0x8000 ) result |= static_cast<int>( IBgfxWin32App::KeyModifier::SHIFT_DOWN );
    if( ( ::GetKeyState( VK_LMENU ) & 0x8000 ) || ( ::GetKeyState( VK_RMENU ) & 0x8000 ) ) result |= static_cast< int >( IBgfxWin32App::KeyModifier::ALT_DOWN );
    if( ( ::GetKeyState( VK_LWIN ) < 0 ) || ( ::GetKeyState( VK_RWIN ) < 0 ) ) result |= static_cast< int >( IBgfxWin32App::KeyModifier::META_DOWN );

    return result;
}
