//
//  BgfxTextureBuffer.h
//  ArtHUD
//
//  Created by clint hidinger on 12/28/19.
//  Copyright © 2019 me. All rights reserved.
//

#pragma once


using BgfxTextureBufferRef = std::shared_ptr<class BgfxTextureBuffer> ;

// http://metalbyexample.com/textures-and-samplers/

class BgfxTextureBuffer
{
public:
    static BgfxTextureBufferRef create() //const ImageSourceRef & imageSource, const Format & format = Format() )
    {
        return BgfxTextureBufferRef( new BgfxTextureBuffer( imageSource, format ) );
    }
private:
    BgfxTextureBuffer(uint16_t _width, uint16_t _height, bool _hasMips, uint16_t _numLayers, bgfx::TextureFormat::Enum _format, uint64_t _flags = BGFX_TEXTURE_NONE | BGFX_SAMPLER_NONE, const bgfx::Memory *_mem = nullptr )
    {
        bgfx::createTexture2D( _width, _height, _hasMips, _numLayers, _format, _flags, _mem );
    }
    
    bgfx::TextureHandle mTex;
};
