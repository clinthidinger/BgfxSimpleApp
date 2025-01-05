//
//  CameraManager.h
//  MetalCamSlices
//
//  Created by William Lindmeier on 2/10/17.
//
//

//#include "cinder/cinder.h"
//#include "metal.h"
#include <map>
#include <bgfx/bgfx.h>
#include "Rect.h"

//#ifdef CINDER_COCOA_TOUCH
#import <CoreVideo/CoreVideo.h>
//#import <AVFoundation/AVFoundation.h>
#import "TextureBuffer.h"
typedef void (^PixelBufferCallback)( CVPixelBufferRef pxBuffer );
typedef void (^FaceDetectionCallback)( const std::map<long, ci::Rectf> & faceRegionsByID );

class CameraManager
{
public:
	struct Options
	{
		Options() :
		mTargetFramerate(60)
		,mTargetWidth(640)
		,mTargetHeight(480)
		,mIsFrontFacing(false)
		,mMipMapLevel(1)
		,mUsesCinematicStabilization(false)
		,mTracksFaces(false)
		{}

	public:

		Options& targetFramerate( int framerate ) { setTargetFramerate( framerate ); return *this; };
		void setTargetFramerate( int framerate ) { mTargetFramerate = framerate; };
		int getTargetFramerate() const { return mTargetFramerate; };

		Options& targetWidth( int width ) { setTargetWidth( width ); return *this; };
		void setTargetWidth( int width ) { mTargetWidth = width; };
		int getTargetWidth() const { return mTargetWidth; };

		Options& targetHeight( int height ) { setTargetHeight( height ); return *this; };
		void setTargetHeight( int height ) { mTargetHeight = height; };
		int getTargetHeight() const { return mTargetHeight; };

		Options& mipMapLevel( int mipMapLevel ) { setMipMapLevel( mipMapLevel ); return *this; };
		void setMipMapLevel( int mipMapLevel ) { mMipMapLevel = mipMapLevel; };
		int getMipMapLevel() const { return mMipMapLevel; };

		Options& isFrontFacing( bool isFrontFacing ) { setIsFrontFacing( isFrontFacing ); return *this; };
		void setIsFrontFacing( bool isFrontFacing ) { mIsFrontFacing = isFrontFacing; };
		bool getIsFrontFacing() const { return mIsFrontFacing; };

		Options& tracksFaces( bool trackFaces ) { setTracksFaces( trackFaces ); return *this; };
		void setTracksFaces( bool trackFaces ) { mTracksFaces = trackFaces; };
		bool getTracksFaces() const { return mTracksFaces; };

		Options& usesCinematicStabilization( bool useCinematicStabilization ) { setUsesCinematicStabilization( useCinematicStabilization ); return *this; };
		void setUsesCinematicStabilization( bool useCinematicStabilization ) { mUsesCinematicStabilization = useCinematicStabilization; };
		bool getUsesCinematicStabilization() const { return mUsesCinematicStabilization; };

	protected:
        int mTargetFramerate{ 60 };
        int mTargetWidth{ 640 };
        int mTargetHeight{ 480 };
        bool mIsFrontFacing{ false };
        bool mTracksFaces{ false };
        bool mUsesCinematicStabilization{ false };
        int mMipMapLevel{ 1 };
	};
	
    CameraManager( id <MTLDevice> device, Options options = Options() );
    
    bool hasTexture();
//	cinder::mtl::TextureBufferRef & getTexture( const int inflightBufferIndex = -1 );
    cinder::mtl::TextureBufferRef &getTexture( const int inflightBufferIndex = -1 );
	double getTimeLastFrame(); // Comes from a CFAbsoluteTime

    void startCapture( id <MTLDevice> device );
    void stopCapture();
    bool isCapturing();
    bool isFrontFacing(){ return mOptions.getIsFrontFacing(); }
    // restartWithOptions is good for toggling between front and back cameras with different resolutions, etc
    void restartWithOptions( id <MTLDevice> device, const Options & options );
    void lockConfiguration( bool isExposureLocked = true, bool isWhiteBalanceLocked = true, bool isFocusLocked = true );
    void unlockConfiguration( bool isExposureUnlocked = true, bool isWhiteBalanceUnlocked = true, bool isFocusUnlocked = true );

	void setPixelBufferCallback( const PixelBufferCallback & pxBufferCallback );
	void setFaceDetectionCallback( const FaceDetectionCallback & faceDetectionCallback );

protected:
    void init();
    void *mImpl{ nullptr };
    bool mIsCapturing{ false };
    Options mOptions;
};
//#endif
