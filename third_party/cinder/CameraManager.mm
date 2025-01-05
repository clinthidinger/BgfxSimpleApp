//
//  CameraManager.m
//  MetalCamSlices
//
//  Created by William Lindmeier on 2/10/17.
//
//
#import "CameraManager.h"
#import <vector>
//#import "Rect.h"
//#ifdef CINDER_COCOA_TOUCH
//!!!#import "RendererMetalImpl.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIDevice.h>
#import <simd/simd.h>
#import <CoreVideo/CVMetalTextureCache.h>
#import <Accelerate/Accelerate.h>
#import <QuartzCore/CAMetalLayer.h>//!!!
#import <Metal/MTLBlitCommandEncoder.h>
#import "cinder-bgfx/TextureBufferLite.h"
#import <CoreVideo/CoreVideo.h>

//#import <AVFoundation/AVFoundation.h>
//#import "TextureBufferLite.h"
//#import "CoreMedia/CMSampleBuffer.h"
//#import "CoreMedia/CMTime.h"
//???#import "cinder-bgfx/Scope.h"
//#import "cinder-bgfx/Scope2.h"


//using namespace std;
using namespace cinder;
using namespace cinder::mtl;

//typedef void (^PixelBufferCallback)( CVPixelBufferRef pxBuffer );
//typedef void (^FaceDetectionCallback)( const std::map<long, CamRectf> &faceRegionsByID );

@interface MTLCameraManager : NSObject <
AVCaptureVideoDataOutputSampleBufferDelegate,
AVCaptureMetadataOutputObjectsDelegate
>

//@property (nonatomic, copy, nullable) PixelBufferCallback pxBufferCallback;
//@property (nonatomic, copy, nullable) FaceDetectionCallback faceDetectionCallback;

@property (nonatomic, nullable) PixelBufferCallback pxBufferCallback;
@property (nonatomic, nullable) FaceDetectionCallback faceDetectionCallback;
@property (nonatomic, nullable) void *pxBufferCallbackUserData;
@property (nonatomic, nullable) void *faceDetectionCallbackUserData;


@end

const int kVideoTextureBufferSize = 2;

@implementation MTLCameraManager
{
    AVCaptureSession *_captureSession;
    CVMetalTextureCacheRef _videoTextureCache;
    AVCaptureDevicePosition _devicePosition;
    AVCaptureDevice* _videoDevice;
    
    //std::vector<ci::mtl::TextureBufferRef> _textures;
#if STORE_TEXTURES
    std::vector<TextureBufferLiteRef> _textures;
#else
    TextureBufferLiteRef _nullTex;
#endif
    int _currVideoTextureIndex;
    int _targetFramerate;
    int _targetWidth;
    int _targetHeight;
    int _mipmapLevel;
    bool _useCinematicStabilization;
	bool _trackFaces;
    bool _storeTexture;
	CFAbsoluteTime _timestampLastFrame;
    //PixelBufferCallback _pxBufferCallback;
    //FaceDetectionCallback _faceDetectionCallback;
}

- (instancetype)initWithOptions:( const CameraManager::Options & )options
{
    self = [super init];
    if ( self )
    {
        _currVideoTextureIndex = -1;
        
        if ( !options.getIsFrontFacing() )
        {
            _devicePosition = AVCaptureDevicePositionBack;
        }
        else
        {
            _devicePosition = AVCaptureDevicePositionFront;
        }

        _targetFramerate = options.getTargetFramerate();
        _targetWidth = options.getTargetWidth();
        _targetHeight = options.getTargetHeight();
        _mipmapLevel = options.getMipMapLevel();
        _useCinematicStabilization = options.getUsesCinematicStabilization();
		_trackFaces = options.getTracksFaces();
        _storeTexture = options.getStoreTexture();
    }
    return self;
}

//- (ci::mtl::TextureBufferRef & )textureRefAtIndex:(int)index
- (TextureBufferLiteRef &)textureRefAtIndex:(int)index
{
#if STORE_TEXTURES
    assert( index >= 0 && index < kVideoTextureBufferSize );
    return _textures[index];
#else
    return _nullTex;
#endif
}

- (bool)hasTexture
{
    return _currVideoTextureIndex >= 0 && _currVideoTextureIndex < kVideoTextureBufferSize;
}

//- (ci::mtl::TextureBufferRef & )lastTexture
- (TextureBufferLiteRef &)lastTexture
{
#if STORE_TEXTURES
    assert([self hasTexture]);
    return _textures[_currVideoTextureIndex];
#else
    return _nullTex;
#endif
}

- (void)start:(id <MTLDevice>)device
{
    if ( _captureSession == nil )
    {
        [self setupCaptureSession:device];//!!!
    }
#if STORE_TEXTURES
	_textures.clear();
    //_textures.assign(kVideoTextureBufferSize, mtl::TextureBufferRef());
    _textures.assign(kVideoTextureBufferSize, nullptr);
#endif
    [_captureSession startRunning];
}

- (void)pause
{
    [_captureSession stopRunning];
}

- (void)unpause
{
    [_captureSession startRunning];
}

- (void)stop
{
    [self pause];
    _captureSession = nil;
#if STORE_TEXTURES
    _textures.clear();
#endif
}

- (CFAbsoluteTime)timestampLastFrame
{
	return _timestampLastFrame;
}

- (void)setupCaptureSession:(id <MTLDevice>)device
{
    _currVideoTextureIndex = -1;

    CVMetalTextureCacheFlush(_videoTextureCache, 0);
    
    //!!!id <MTLDevice> device = [RendererMetalImpl sharedRenderer].device;
    CVReturn textureCacheError = CVMetalTextureCacheCreate(kCFAllocatorDefault, NULL, device, NULL, &_videoTextureCache);
    
    if (textureCacheError)
    {
        NSLog(@">> ERROR: Couldnt create a texture cache");
        assert(0);
    }
    
    // Make and initialize a capture session
    _captureSession = [[AVCaptureSession alloc] init];
    
    if (!_captureSession)
    {
        NSLog(@">> ERROR: Couldnt create a capture session");
        assert(0);
    }
    
    [_captureSession beginConfiguration];
    
    // Get the a video device with preference to the front facing camera
    _videoDevice = nil;
    //NSArray* captureDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceDiscoverySession *captureDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
    mediaType:AVMediaTypeVideo
     position:AVCaptureDevicePositionBack];
    NSArray *captureDevices = [captureDeviceDiscoverySession devices];
    for ( AVCaptureDevice* device in captureDevices )
    {
        if ( [device position] == _devicePosition )
        {
            _videoDevice = device;
        }
    }
    
    if ( _videoDevice == nil)
    {
        _videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    if ( _videoDevice == nil )
    {
        NSLog(@">> ERROR: Couldnt create a AVCaptureDevice");
        assert(0);
    }
    
    NSError *error;
    
    // Device input
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:&error];
    
    if (error)
    {
        NSLog(@">> ERROR: Couldnt create AVCaptureDeviceInput %@", error);
        assert(0);
    }
    
    [_captureSession addInput:deviceInput];
        
    // Create the output for the capture session.
    AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    // Set the color space.
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                             forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    // Set dispatch to be on the main thread to create the texture in memory and allow Metal to use it for rendering
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];

    // Frame Rate
    {//*
        if (_videoDevice.activeFormat.videoSupportedFrameRateRanges)
        {
            const int CAPTURE_FRAMES_PER_SECOND = 3;
            
            _videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
            _videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
        }
       //*/
        //AVCaptureConnection *conn = [dataOutput connectionWithMediaType:AVMediaTypeVideo];
    //if (conn.isVideoMinFrameDurationSupported)
    //    conn.videoMinFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
    //if (conn.isVideoMaxFrameDurationSupported)
    //    conn.videoMaxFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
    }
    
	// Face tracking

	if ( _trackFaces )
	{
		AVCaptureMetadataOutput* output = [[AVCaptureMetadataOutput alloc] init];
		[output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
		if ([_captureSession canAddOutput:output])
		{
			[_captureSession addOutput:output];
		}

		// NOW try adding metadata types
		output.metadataObjectTypes = @[AVMetadataObjectTypeFace];
	}

    NSError *deviceConfigError = nil;
    [_videoDevice lockForConfiguration:&deviceConfigError];

    bool didPickExactFormat = false;
    AVCaptureDeviceFormat *bestFormat = nil;
    
    for ( AVCaptureDeviceFormat *format in _videoDevice.formats )
    {
        CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        if ( int(dimensions.width) == _targetWidth && int(dimensions.height) == _targetHeight )
        {
            for ( AVFrameRateRange *range in format.videoSupportedFrameRateRanges )
            {
                bestFormat = format;
                if ( range.minFrameRate <= _targetFramerate && range.maxFrameRate >= _targetFramerate )
                {
                    _videoDevice.activeFormat = format;
                    [_videoDevice setActiveVideoMinFrameDuration:CMTimeMake(1,_targetFramerate)];
                    [_videoDevice setActiveVideoMaxFrameDuration:CMTimeMake(1,_targetFramerate)];
                    didPickExactFormat = true;
                    break;
                }
            }
        }
        if ( didPickExactFormat )
        {
            break;
        }
    }
    
    if ( !didPickExactFormat )
    {
        NSLog(@"WARNING: Couldn't find a preset that fit your options.");
        
        if ( bestFormat )
        {
            _videoDevice.activeFormat = bestFormat;
        }
        else
        {
            NSLog(@"Defaulting to preset");
            _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
        }
        
        for ( AVCaptureDeviceFormat *format in _videoDevice.formats )
        {
            NSLog(@"Format: %@", format);
            for ( AVFrameRateRange *range in format.videoSupportedFrameRateRanges )
            {
                NSLog(@"Framerate Range: %@", range);
            }
        }
    }
    
    if ( _useCinematicStabilization )
    {
        if ( ![_videoDevice.activeFormat isVideoStabilizationModeSupported:AVCaptureVideoStabilizationModeCinematic] )
        {
            for ( AVCaptureDeviceFormat *format in _videoDevice.formats )
            {
                if ( [format isVideoStabilizationModeSupported:AVCaptureVideoStabilizationModeCinematic] )
                {
                    NSLog(@"Format supports video stabilization: %@", format);
                }
            }
        }
        else
        {
            NSLog(@"Active format supports video stabilization");
        }
    }

    _videoDevice.videoZoomFactor = 1.0f;
    
    [_videoDevice unlockForConfiguration];
    
    if ( deviceConfigError )
    {
        NSLog(@">> ERROR: Couldnt configure device");
        assert(0);
    }
    
    NSLog(@"videoDevice.activeFormat: %@", _videoDevice.activeFormat);

    [_captureSession addOutput:dataOutput];
    [_captureSession commitConfiguration];
}

- (void)setConfigurationLock:(BOOL)isLocked forExposure:(BOOL)exposureLock whiteBalance:(BOOL)whiteBalanceLock focus:(BOOL)focusLock
{
    assert(_videoDevice != nil);
    
    [_captureSession beginConfiguration];
    
    NSError *error = nil;
    [_videoDevice lockForConfiguration:&error];
    if ( error )
    {
        NSLog(@"Video configuration error: %@", error);
        return;
    }
    
    if ( whiteBalanceLock )
    {
        AVCaptureWhiteBalanceMode newMode = isLocked ? AVCaptureWhiteBalanceModeLocked : AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        if ( [_videoDevice isWhiteBalanceModeSupported:newMode] )
        {
            _videoDevice.whiteBalanceMode = newMode;
            NSLog(@"Whitebalanced locked");
        }
        else
        {
            NSLog(@"WARNING: Whitebalance mode not supported");
        }
    }
    
    if ( exposureLock )
    {
        AVCaptureExposureMode newMode = isLocked ? AVCaptureExposureModeLocked : AVCaptureExposureModeContinuousAutoExposure;
        if ( [_videoDevice isExposureModeSupported:newMode] )
        {
            _videoDevice.exposureMode = newMode;
            NSLog(@"Exposure locked");
        }
        else
        {
            NSLog(@"WARNING: Exposure mode not supported");
        }
    }
    
    if ( focusLock )
    {
        AVCaptureFocusMode newMode = isLocked ? AVCaptureFocusModeLocked : AVCaptureFocusModeContinuousAutoFocus;
        if ( [_videoDevice isFocusModeSupported:newMode] )
        {
            _videoDevice.focusMode = newMode;
            NSLog(@"Focus locked");
        }
        else
        {
            NSLog(@"WARNING: Focus mode not supported");
        }
    }
    
    [_videoDevice unlockForConfiguration];
    [_captureSession commitConfiguration];
}

void ReleasePixelData( void * __nullable info, const void *data );
void ReleasePixelData( void * __nullable info, const void *data )
{
    free((void *)data);
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects
	   fromConnection:(AVCaptureConnection *)connection
{
	if ( self.faceDetectionCallback == nullptr )
    {
        return;
    }

	std::map<long, CamRectf> faceRegionsByID;

	for ( AVMetadataObject * metadata in metadataObjects )
	{
		if ( [metadata isKindOfClass:[AVMetadataFaceObject class]] )
		{
			AVMetadataFaceObject *faceObject = (AVMetadataFaceObject*)metadata;

			CGRect bounds = metadata.bounds;
            CamRectf roi{ static_cast<float>( bounds.origin.x ),
					      static_cast<float>( bounds.origin.y ),
					      static_cast<float>( bounds.origin.x + bounds.size.width ),
                          static_cast<float>( bounds.origin.y + bounds.size.height ) };
			
			faceRegionsByID[faceObject.faceID] = roi;
		}
	}

	self.faceDetectionCallback(faceRegionsByID, self.faceDetectionCallbackUserData );
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
	   fromConnection:(AVCaptureConnection *)connection
{
    // Is this the best place to put this? Seems like it should be in the setup.
    if ( _useCinematicStabilization &&
         connection.activeVideoStabilizationMode != AVCaptureVideoStabilizationModeCinematic )
    {
        NSLog(@"Enabling cinematic stabilization");
        connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeCinematic;
    }

    CVReturn error;
    
    
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    if( !_storeTexture )
    {
    // http://jamesalvarez.co.uk/uncategorized/reading-cvpixelbuffer-in-objective-c/
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow( pixelBuffer );
        
        CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
        
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress( pixelBuffer );

        OSType type = CVPixelBufferGetPixelFormatType( pixelBuffer );
        if( type != kCVPixelFormatType_32BGRA )//kCVPixelFormatType_DepthFloat32 )
        {
            //NSLog(@"Wrong type");
        }
        // Locking is only necessary when we access buffer on CPU.
       
        
        if ( self.pxBufferCallback != nullptr )
        {
            self.pxBufferCallback( baseAddress, width, height, 4, self.pxBufferCallbackUserData );
        }
        
        //int baseAddressIndex = y  * bytesPerRow + x  * sizeof(Float32);
        //const Float32 pixel = *(Float32*)(&baseAddress[0]);
        
         CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
        
        //bgfx::Memory *mem = bgfx::makeRef( baseAddress, width * height * sizeof(Float32) );
        //struct Memory
        //{
        //    uint8_t* data; //!< Pointer to data.
        //    uint32_t size; //!< Data size.
        //};
        return;
    }
    
    // Lets try cropping with vimage
    // http://stackoverflow.com/questions/29171752/how-do-you-scale-an-image-using-vimage-in-the-accelerate-framework-in-ios-8
    
#if STORE_TEXTURES
    CVMetalTextureRef textureRef;
    error = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                      _videoTextureCache,
                                                      pixelBuffer,
                                                      NULL,
                                                      MTLPixelFormatBGRA8Unorm,
                                                      width,
                                                      height,
                                                      0,
                                                      &textureRef);
    
    if (error)
    {
        NSLog(@">> ERROR: Couldnt create texture from image: %i", error);
        assert(0);
    }

    int texIndex = (_currVideoTextureIndex + 1) % kVideoTextureBufferSize;
    id <MTLTexture> texture = CVMetalTextureGetTexture(textureRef);
    if (!texture )
    {
        NSLog(@">> ERROR: Couldn't get texture from texture ref");
        assert(0);
    }
    
    /*
    if ( _mipmapLevel > 1 )
    {
        auto mipMappedTexture = TextureBufferLite::create( (uint)width,
                                                           (uint)height,
                                                           TextureBufferLite::Format()
                                                               .mipmapLevel(_mipmapLevel)
                                                               .pixelFormat(mtl::PixelFormat::PixelFormatBGRA8Unorm)
                                                          );
        id <MTLTexture> mtlMipMapTex = (__bridge id <MTLTexture>)mipMappedTexture->getNative();
        mtl::ScopedCommandBuffer commandBuffer;
        mtl::ScopedBlitEncoder blitEncoder = commandBuffer.scopedBlitEncoder();
        id <MTLBlitCommandEncoder> encoder = (__bridge id <MTLBlitCommandEncoder>)blitEncoder.getNative();
        [encoder copyFromTexture:texture
                      sourceSlice:0
                      sourceLevel:0
                     sourceOrigin:MTLOriginMake(0, 0, 0)
                       sourceSize:MTLSizeMake(width, height, 1)
                        toTexture:mtlMipMapTex
                 destinationSlice:0
                 destinationLevel:0
                destinationOrigin:MTLOriginMake(0, 0, 0)];
        
        // Now generate the mip-maps
        [encoder generateMipmapsForTexture:mtlMipMapTex];

        _textures[texIndex] = mipMappedTexture;
    }
    else
     */
    {
        /*
        {
            #define IMPL ((__bridge id <MTLTexture>)mImpl)
            
            if ( mImpl )
            {
                CFRelease(mImpl);
                mImpl = nullptr;
            }
            assert( mtlTexture != nullptr );
            assert( [(__bridge id)mtlTexture conformsToProtocol:@protocol(MTLTexture)] );
            mImpl = mtlTexture;
            CFRetain(mImpl);
            
            //---
            
            PixelFormat pxFormat = (PixelFormat)[IMPL pixelFormat];
            mDataType = dataTypeFromPixelFormat(pxFormat);
            
            int numChannels = channelCountFromPixelFormat(pxFormat);
            assert( numChannels > 0 && numChannels != 3 );

            mBytesPerRow = dataSizeForType( mDataType ) * [IMPL width] * numChannels;

            mFormat = Format()
                        .pixelFormat(pxFormat)
                        .mipmapLevel((int)[IMPL mipmapLevelCount])
                        .sampleCount((int)[IMPL sampleCount])
                        .depth((int)[IMPL depth])
                        .arrayLength((int)[IMPL arrayLength])
                        .usage((mtl::TextureUsage)[IMPL usage])
                        .storageMode((mtl::StorageMode)[IMPL storageMode])
                        .cacheMode((mtl::CPUCacheMode)[IMPL cpuCacheMode]);
            
        }
          bgfx::TextureMtl t;
         */
       
        auto tex = TextureBufferLite::create((__bridge void *)texture);
        assert(tex != nullptr);
        _textures[texIndex] = tex;
    }
    
    _currVideoTextureIndex = texIndex;
#endif
	if ( self.pxBufferCallback != nullptr )
	{
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress( pixelBuffer );
        self.pxBufferCallback( baseAddress, width, height, sizeof(Float32), self.pxBufferCallbackUserData );
		//self.pxBufferCallback(pixelBuffer);
	}

#if STORE_TEXTURES
    CVBufferRelease(textureRef);
#endif
    
	_timestampLastFrame = CFAbsoluteTimeGetCurrent();
}

/*
// https://stackoverflow.com/questions/9694859/ios-taking-photo-programmatically
- (IBAction)btnCaptureImagePressed:(id)sender {

     AVCaptureConnection * videoConnection =  [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];

    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef  _Nullable sampleBuffer, NSError * _Nullable error) {
       NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
        UIImage *image = [[UIImage alloc]initWithData: imageData];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }];
}
*/

@end

#define IMPL ((__bridge MTLCameraManager *)mImpl)

CameraManager::CameraManager( Options options ) :
mImpl( nullptr )
,mIsCapturing ( false )
,mOptions(options)
{
    init();
}

void CameraManager::setPixelBufferCallback( const PixelBufferCallback &pxBufferCallback, void *userData )
{
	IMPL.pxBufferCallback = pxBufferCallback;
    IMPL.pxBufferCallbackUserData = userData;
}

void CameraManager::setFaceDetectionCallback( const FaceDetectionCallback &faceDetectionCallback, void *userData )
{
	IMPL.faceDetectionCallback = faceDetectionCallback;
    IMPL.faceDetectionCallbackUserData = userData;
}

void CameraManager::init()
{
	mImpl = (__bridge_retained void *)[[MTLCameraManager alloc] initWithOptions:mOptions];
}

void CameraManager::startCapture( void *dev )
{
    if ( !mIsCapturing )
    {
        id <MTLDevice> device = (__bridge id <MTLDevice>)dev;
        assert( mImpl != nullptr );
        mIsCapturing = true;
        [IMPL start:device];
    }
}

double CameraManager::getTimeLastFrame()
{
	return [IMPL timestampLastFrame];
}

void CameraManager::stopCapture()
{
    if ( mIsCapturing )
    {
        assert( mImpl != nullptr );
        mIsCapturing = false;
        [IMPL stop];
    }
}

void CameraManager::pauseCapture()
{
    [IMPL pause];
}

//void CameraManager::unpauseCapture()
//{
//    [IMPL unpause];
//}

void CameraManager::restartWithOptions( void *device, const Options & options )
{
	if ( isCapturing() )
    {
        stopCapture();
    }
    mOptions = options;
	PixelBufferCallback pxBufferCallback = IMPL.pxBufferCallback;
	FaceDetectionCallback faceDetectCallback = IMPL.faceDetectionCallback;
    void *pxBufferCallbackUserData = IMPL.pxBufferCallbackUserData;
    void *faceDetectCallbackUserData = IMPL.faceDetectionCallbackUserData;
    init();
	IMPL.pxBufferCallback = pxBufferCallback; // reset the callback if there was one
	IMPL.faceDetectionCallback = faceDetectCallback; // ditto
    IMPL.pxBufferCallbackUserData = pxBufferCallbackUserData;
    IMPL.faceDetectionCallbackUserData = faceDetectCallbackUserData;
    
    startCapture( device );
}

void CameraManager::lockConfiguration( bool isExposureLocked, bool isWhiteBalanceLocked, bool isFocusLocked )
{
    [IMPL setConfigurationLock:YES forExposure:isExposureLocked whiteBalance:isWhiteBalanceLocked focus:isFocusLocked];
}

void CameraManager::unlockConfiguration( bool isExposureUnlocked, bool isWhiteBalanceUnlocked, bool isFocusUnlocked )
{
    [IMPL setConfigurationLock:NO forExposure:isExposureUnlocked whiteBalance:isWhiteBalanceUnlocked focus:isFocusUnlocked];
}

bool CameraManager::isCapturing()
{
    return mIsCapturing;
}

bool CameraManager::hasTexture()
{
    return mIsCapturing && [IMPL hasTexture];
}

//mtl::TextureBufferRef & CameraManager::getTexture( const int inflightBufferIndex )
TextureBufferLiteRef &CameraManager::getTexture( const int inflightBufferIndex )
{
    if ( inflightBufferIndex >= 0 )
    {
        return [IMPL textureRefAtIndex:inflightBufferIndex];
    }
    return [IMPL lastTexture];
}
//#endif
