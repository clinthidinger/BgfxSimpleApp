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
            mApp->render( mApp->getWidth(), mApp->getHeight(), 1.0f );
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
#ifdef TABLET_APP
            mTablet->close();
            mTablet.reset();
            WinTablet::unload();
#endif
            //Called in destructor: mApp.shutdown();
            mApp.reset();
            PostQuitMessage( 0 ); // this triggers the WM_QUIT to break the loop
            break;
        }
        case WM_DROPFILES:
        {
            //*
            HDROP drop = reinterpret_cast<HDROP>( wParam );
            char tmp[bx::kMaxFilePath];
            WCHAR utf16[bx::kMaxFilePath];
            // This only gets the first file.  Maybe look at cinder source to see how to do it better.
            uint32_t result = DragQueryFileW( drop, 0, utf16, bx::kMaxFilePath );
            BX_UNUSED( result );
            WideCharToMultiByte( CP_UTF8, 0, utf16, -1, tmp, bx::kMaxFilePath, nullptr, nullptr );
            //WindowHandle handle = findHandle( hwnd );
            //m_eventQueue.postDropFileEvent( handle, tmp );
            //mApp->handleFileDrop( filePath );
            //*/
            break;
        }
        case WM_LBUTTONDOWN:
        {
            mApp->handleMouseDown( 0, LOWORD( lParam ), HIWORD( lParam ) );
            mMouseButtonState[0] = 1;
            break;
        }
        case WM_LBUTTONUP:
        {
            mApp->handleMouseUp( 0, LOWORD( lParam ), HIWORD( lParam ) );
            mMouseButtonState[0] = 0;
            break;
        }
        case WM_RBUTTONDOWN:
        {
            mApp->handleMouseDown( 1, LOWORD( lParam ), HIWORD( lParam ) );
            mMouseButtonState[1] = 1;
            break;
        }
        case WM_RBUTTONUP:
        {
            mApp->handleMouseUp( 1, LOWORD( lParam ), HIWORD( lParam ) );
            mMouseButtonState[1] = 0;
            break;
        }
        case WM_MBUTTONDOWN:
        {
            mApp->handleMouseDown( 2, LOWORD( lParam ), HIWORD( lParam ) );
            mMouseButtonState[2] = 1;
            break;
        }
        case WM_MBUTTONUP:
        {
            mApp->handleMouseUp( 2, LOWORD( lParam ), HIWORD( lParam ) );
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
                    mApp->handleMouseDrag( mouseButton, LOWORD( lParam ), HIWORD( lParam ) );
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
                mApp->handleMouseWheel( LOWORD( lParam ),
                                        HIWORD( lParam ),
                                        static_cast<int>( GET_WHEEL_DELTA_WPARAM( wParam ) / static_cast<float>( WHEEL_DELTA ) ) );
            }
            break;
        }
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
