//
//  IBgfxApp.h
//
//  Created by clint hidinger on 1/2/20.
//  Copyright © 2020 me. All rights reserved.
//

#pragma once

class IBgfxApp
{
public:
    virtual ~IBgfxApp() = default;
    virtual void init( int width, int height, float scaleFactor, void *nwh, void *context ) = 0;
    virtual void render( int width, int height, float scaleFactor ) = 0;
    virtual void resize( int width, int height, float scaleFactor ) = 0;
    virtual void update() = 0;
    virtual void shutdown() = 0;
    virtual bool enableAutoRefresh() = 0;
};
