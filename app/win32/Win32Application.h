#pragma once

#include "framework.h"//#include <windows.h>
#include <memory>
#include "IBgfxWin32App.h"

class IBgfxWin32App;

// Note: Based on DirectX samples.
class Win32Application
{
public:
    using AppType = IBgfxWin32App;
    static int Run( std::unique_ptr<AppType> app, HINSTANCE hInstance, int nCmdShow );
    static inline HWND GetHwnd();

protected:
    static LRESULT CALLBACK WindowProc( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam );

private:
    static int GetKeyModifiers();
    static HWND mHwnd;
    static std::unique_ptr<AppType> mApp;
    static int mFrameNum;
    static int mMouseButtonState[3];
};

inline HWND Win32Application::GetHwnd() { return mHwnd; }
