
//
//  TextureBuffer.hpp
//
//  Created by William Lindmeier on 10/30/15.
//
//

#pragma once

//#include "cinder/Cinder.h"
//#include "cinder/ImageIo.h"
//#include "MetalHelpers.hpp"
#import <Metal/Metal.h>

#include <stdint.h>
#include <memory>
#include "MetalEnums.h"
#include "ImageHelpers.h"

namespace cinder { namespace mtl {
    
    using TextureBufferLiteRef = std::shared_ptr<class TextureBufferLite> ;
    
    // http://metalbyexample.com/textures-and-samplers/
    
    class TextureBufferLite
    {
        
        //friend class ImageSourceTextureBuffer;
        
    public:
        using uint = unsigned int;
        struct Format
        {
            //*
            Format() :
            mMipmapLevel(1)
            ,mSampleCount(1)
            ,mTextureType(TextureType2D)
            ,mPixelFormat(PixelFormatInvalid)
            ,mDepth(1)
            ,mArrayLength(1)
            ,mUsage(TextureUsageShaderRead)
            ,mFlipVertically(false)
#if defined( CINDER_COCOA_TOUCH )
            ,mStorageMode( StorageModeShared )
#else
            // NOTE: On OS X, programs run faster in "Shared" mode when using the integrated GPU,
            // and faster in "Managed" mode when using the descreet GPU.
            ,mStorageMode( StorageModeManaged )
#endif
            ,mCacheMode( CPUCacheModeDefaultCache )

            {};

        //public:
            //*/
            Format& mipmapLevel( int mipmapLevel ) { setMipmapLevel( mipmapLevel ); return *this; };
            void setMipmapLevel( int mipmapLevel ) { mMipmapLevel = mipmapLevel; };
            int getMipmapLevel() const { return mMipmapLevel; };

            Format& sampleCount( int sampleCount ) { setSampleCount( sampleCount ); return *this; };
            void setSampleCount( int sampleCount ) { mSampleCount = sampleCount; };
            int getSampleCount() const { return mSampleCount; };

            Format& textureType( TextureType textureType ) { setTextureType( textureType ); return *this; };
            void setTextureType( TextureType textureType ) { mTextureType = textureType; };
            TextureType getTextureType() const { return mTextureType; };

            Format& pixelFormat( PixelFormat pixelFormat ) { setPixelFormat( pixelFormat ); return *this; };
            void setPixelFormat( PixelFormat pixelFormat ) { mPixelFormat = pixelFormat; };
            PixelFormat getPixelFormat() const { return mPixelFormat; };

            Format& flipVertically( bool flipVertically = true ) { setFlipVertically( flipVertically ); return *this; };
            void setFlipVertically( bool flipVertically ) { mFlipVertically = flipVertically; };
            bool getFlipVertically() const { return mFlipVertically; };

            Format& depth( int depth ) { setDepth( depth ); return *this; };
            void setDepth( int depth ) { mDepth = depth; };
            int getDepth() const { return mDepth; };

            Format& arrayLength( int arrayLength ) { setArrayLength( arrayLength ); return *this; };
            void setArrayLength( int arrayLength ) { mArrayLength = arrayLength; };
            int getArrayLength() const { return mArrayLength; };

            Format& usage( TextureUsage usage ) { setUsage( usage ); return *this; };
            void setUsage( TextureUsage usage ) { mUsage = usage; };
            TextureUsage getUsage() const { return mUsage; };

            Format& storageMode( StorageMode storageMode ) { setStorageMode( storageMode ); return *this; };
            void setStorageMode( StorageMode storageMode ) { mStorageMode = storageMode; };
            StorageMode getStorageMode() const { return mStorageMode; };
            
            Format& cacheMode( CPUCacheMode cacheMode ) { setCacheMode( cacheMode ); return *this; };
            void setCacheMode( CPUCacheMode cacheMode ) { mCacheMode = cacheMode; };
            CPUCacheMode getCacheMode() const { return mCacheMode; };

        protected:
            
            int mMipmapLevel{ 1 };
            int mSampleCount{ 1 };
            TextureType mTextureType{ TextureType2D };
            PixelFormat mPixelFormat{ PixelFormatInvalid };
            int mDepth{ 1 };
            int mArrayLength{ 1 };
            TextureUsage mUsage{ TextureUsageShaderRead };
            bool mFlipVertically{ false };
            StorageMode mStorageMode{ StorageModeShared };
            CPUCacheMode mCacheMode{ CPUCacheModeDefaultCache };
        };
        
        //static TextureBufferLiteRef create( const ImageSourceRef & imageSource, const Format & format = Format() )
        //{
        //    return TextureBufferLiteRef( new TextureBufferLite( imageSource, format ) );
        //}

        static TextureBufferLiteRef create( id <MTLDevice> device, uint width, uint height, const Format & format = Format() )
        {
            return TextureBufferLiteRef( new TextureBufferLite( device, width, height, format ) );
        }
        
        static TextureBufferLiteRef create( void * mtlTexture )
        {
            return TextureBufferLiteRef( new TextureBufferLite( mtlTexture ) );
        }

        // What's the right way to handle copy?
        //TextureBufferLiteRef clone( id<MTLDevice> device );

        virtual ~TextureBufferLite();

        //void update( const ImageSourceRef & imageSource, unsigned int slice = 0, unsigned int mipmapLevel = 0 );
        void update( void * mtlTexture );
        //void updateWithCGImage( void *, bool flipVertically, unsigned int slice = 0, unsigned int mipmapLevel = 0 );
        
        // Getting & Setting Data for 2D images
        void setPixelData( const void *pixelBytes, unsigned int slice = 0, unsigned int mipmapLevel = 0 );
        void getPixelData( void *pixelBytes, unsigned int slice = 0, unsigned int mipmapLevel = 0 );
        void getPixelData( void *pixelBytes, int x, int y, int width, int height,
                           unsigned int slice = 0, unsigned int mipmapLevel = 0);

        //ci::ImageSourceRef createSource( int slice = 0, int mipmapLevel = 0 );

        // Accessors
        Format      getFormat() const;
        long        getWidth() const;
        long        getHeight() const;
        long        getDepth() const;
        //ci::ivec2    getSize() const { return ivec2( getWidth(), getHeight() ); }
        long        getMipmapLevelCount();
        long        getSampleCount();
        long        getArrayLength();
        bool        getFramebufferOnly();
        TextureUsage getUsage(); // <MTLTextureUsage>
        
        //void getBytes( void * pixelBytes, const ivec3 regionOrigin, const ivec3 regionSize,
        //               uint bytesPerRow, uint bytesPerImage, uint mipmapLevel = 0, uint slice = 0);
        
        //void replaceRegion( const ivec3 regionOrigin, const ivec3 regionSize, const void * newBytes,
        //                    uint bytesPerRow, uint bytesPerImage, uint mipmapLevel = 0, uint slice = 0 );
        
        //void replaceRegion(const ivec2 regionOrigin, const ivec2 regionSize, const void * newBytes,
        //                   uint bytesPerRow, uint mipmapLevel = 0);

        TextureBufferLiteRef newTexture( PixelFormat pixelFormat, TextureType type, uint levelOffset = 0,
                                    uint levelLength = 1, uint sliceOffset = 0, uint sliceLength = 1 );
        
        void *getNative() { return mImpl; };

    protected:

        //TextureBufferLite( const ImageSourceRef & imageSource, Format format );
        TextureBufferLite( id <MTLDevice> device, uint width, uint height, Format format );
        TextureBufferLite( void * mtlTexture );

        void generateMipmap( id<MTLDevice> device );
        
        void *mImpl{ nullptr }; // <MTLTexture>
        long mBytesPerRow{ 0 };
        Format mFormat;

        ImageIo::DataType mDataType;

    };
    
} }
