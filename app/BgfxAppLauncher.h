//
//  BgfxAppLauncher.h
//  ArtHUD
//
//  Created by clint hidinger on 1/2/20.
//  Copyright © 2020 me. All rights reserved.
//

#pragma once

template <typename BgfxAppInterfaceType>
class BgfxAppLauncher
{
public:
    BgfxAppLauncher( const BgfxAppLauncher & ) = delete;
    BgfxAppLauncher& operator=( const BgfxAppLauncher & ) = delete;
    BgfxAppLauncher( BgfxAppLauncher && ) = delete;
    BgfxAppLauncher & operator=( BgfxAppLauncher && ) = delete;

    static auto& instance()
    {
        static BgfxAppLauncher launcher;
        return launcher;
    }
    
    BgfxAppInterfaceType *getApp() { return mBgfxApp; }
    const BgfxAppInterfaceType *getApp() const { return mBgfxApp; }
    void setApp( BgfxAppInterfaceType *app ) { mBgfxApp = app; }
    void deleteApp()
    {
        if( mBgfxApp != nullptr )
        {
            delete mBgfxApp;
            mBgfxApp = nullptr;
        }
    }
private:
    BgfxAppLauncher() = default;
    ~BgfxAppLauncher()
    {
        deleteApp();
    }
    //std::unique_ptr<BgfxAppInterfaceType> mBgfxApp;
    BgfxAppInterfaceType *mBgfxApp{ nullptr };
};
