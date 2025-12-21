//
//  GameViewController.m
//  ArtHUD
//
//  Created by clint hidinger on 12/11/19.
//  Copyright © 2019 me. All rights reserved.
//

#import "GameViewController.h"
#import "Renderer.h"
#include <bgfx/platform.h>
#include "BgfxiOSAppLauncher.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>


//https://github.com/Milan-Shah/SLComposeController---Social-Share-over-Extension/blob/61084f64f0d3e7de760b96272b679a3673d5469e/SLCompose%20Twitter%20%26%20FaceBook/ViewController.m
//https://gist.github.com/keicoder/9224472
//https://gist.github.com/keicoder/9681278

//https://developer.apple.com/library/archive/samplecode/PhotoPicker/Introduction/Intro.html#//apple_ref/doc/uid/DTS40010196-Intro-DontLinkElementID_2

@interface GameViewController()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property(nullable, nonatomic,readonly,strong) UINavigationController *navigationController;

@end


@implementation GameViewController
{
    MTKView *_view;

    Renderer *_renderer;
    
    std::unique_ptr<uint8_t[]> _imageRawData;
    
    unsigned long _imageRawDataSize;
    
    UIActivityIndicatorView *_indicator;
    //ImageCropView *_imageCropView;
}

- (UIActivityIndicatorView *)indicator {
    //https://pinkstone.co.uk/how-to-display-a-spinning-wheel-indicator-in-the-centre-of-your-screen/
    if (!_indicator) {
        if (@available(iOS 13.0, *)) {
            _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        } else {
            _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
    }
    return _indicator;
}

- (void)loadView
{
    // Create MTKView as the main view
    MTKView *mtkView = [[MTKView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = mtkView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _view = (MTKView *)self.view;

    _view.device = MTLCreateSystemDefaultDevice();
    _view.backgroundColor = UIColor.blackColor;

    if(!_view.device)
    {
        NSLog(@"Metal is not supported on this device");
        self.view = [[UIView alloc] initWithFrame:self.view.frame];
        
        return;
    }

    _renderer = [[Renderer alloc] initWithMetalKitView:_view];

    //[_renderer mtkView:_view drawableSizeWillChange:_view.bounds.size];
    //[_renderer mtkView:_view drawableSizeWillChange:_view.drawableSize];

    _view.delegate = _renderer;
    
    // Setup gesture recognizers
    [self setupGestures];
    
    // Setup keyboard and mouse handling
    [self setupKeyboardAndMouse];
    
     //_imageCropView = [ImageCropView alloc];
    
    // app->setRefeshFunc( [view] () { [view setNeedsDisplay]; } );
    _imageRawDataSize = 0;
#ifdef ENABLE_CAMERA
    BgfxiOSAppLauncher::instance().getApp()->setShowImagePickerPhotoFunc([self] () {
        [self showImagePickerPhotos];
    });
    BgfxiOSAppLauncher::instance().getApp()->setShowImagePickerCameraFunc([self] () {
        [self showImagePickerCamera];
    });
#endif
//    BgfxiOSAppLauncher::instance().getApp()->setShowImageCropperFunc([self] () {
//        [self showImageCropper];
//    });
    
    self.indicator.center = self.view.center;
    [self.view addSubview:self.indicator];
    
    BgfxiOSAppLauncher::instance().getApp()->setEnableIndicatorFunc([self] (bool state) {
        if( state ) {
            [self.indicator startAnimating];
        }
        else {
            [self.indicator stopAnimating];
        }
    });
}

// Note: these two funcs prevent landscape.
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)showImagePickerPhotos
{
    [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary]; // UIImagePickerControllerSourceTypeSavedPhotosAlbum
}

- (void)showImagePickerCamera
{
    [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
}

//- (void)showImageCropper
//{
//    /*
//    //imageCropView.image = [UIImage imageNamed:@"pict.jpeg"];
//    //imageCropView.controlColor = [UIColor cyanColor];
//    //if(image != nil) {
//        ImageCropViewController *controller = [[ImageCropViewController alloc] initWithImage:image];
//        controller.delegate = self;
//        controller.blurredBackground = YES;
//        // set the cropped area
//        // controller.cropArea = CGRectMake(0, 0, 100, 200);
//        [[self navigationController] pushViewController:controller animated:YES];
//    //}
//     */
//}

//#pragma mark - IBActions
//- (IBAction)pickImageButtonClicked:(id)sender
- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType {
    // Check permissions first
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self checkCameraPermissionAndShowPicker:sourceType];
    } else {
        [self checkPhotoLibraryPermissionAndShowPicker:sourceType];
    }
}

- (void)checkCameraPermissionAndShowPicker:(UIImagePickerControllerSourceType)sourceType {
    AVAuthorizationStatus cameraStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (cameraStatus) {
        case AVAuthorizationStatusAuthorized:
        {
            [self presentImagePicker:sourceType];
            break;
        }
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self presentImagePicker:sourceType];
                    } else {
                        [self showPermissionDeniedAlert:@"Camera"];
                    }
                });
            }];
            break;
        }
        default:
        {
            [self showPermissionDeniedAlert:@"Camera"];
            break;
        }
    }
}

- (void)checkPhotoLibraryPermissionAndShowPicker:(UIImagePickerControllerSourceType)sourceType {
    PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
    
    switch (photoStatus) {
        case PHAuthorizationStatusAuthorized:
        case PHAuthorizationStatusLimited:
        {
            [self presentImagePicker:sourceType];
            break;
        }
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
                        [self presentImagePicker:sourceType];
                    } else {
                        [self showPermissionDeniedAlert:@"Photo Library"];
                    }
                });
            }];
            break;
        }
        default:
        {
            [self showPermissionDeniedAlert:@"Photo Library"];
            break;
        }
    }
}

- (void)presentImagePicker:(UIImagePickerControllerSourceType)sourceType {
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        NSLog(@"Source type not available: %ld", (long)sourceType);
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePicker.allowsEditing = NO;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    }
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)showPermissionDeniedAlert:(NSString *)permissionType {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Permission Required"
                                                                   message:[NSString stringWithFormat:@"Please enable %@ access in Settings to use this feature.", permissionType]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:settingsAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Input Setup

- (void)setupKeyboardAndMouse {
    // Enable keyboard support for external keyboards
    if (@available(iOS 13.4, *)) {
        // Add support for pointer interactions (trackpad/mouse on iPad)
        UIPanGestureRecognizer *pointerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePointerPan:)];
        pointerPan.allowedScrollTypesMask = UIScrollTypeMaskAll;
        pointerPan.delegate = self;
        [self.view addGestureRecognizer:pointerPan];
        
        // Add hover gesture for mouse move events
        UIHoverGestureRecognizer *hover = [[UIHoverGestureRecognizer alloc] initWithTarget:self action:@selector(handleHover:)];
        [self.view addGestureRecognizer:hover];
    }
    
    // Make view first responder to receive keyboard events
    [self.view becomeFirstResponder];
    self.view.userInteractionEnabled = YES;
}

#pragma mark - Gesture Setup

- (void)setupGestures {
    // Remove any existing gesture recognizers
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:recognizer];
    }
    
    // Single tap
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    
    // Double tap
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delegate = self;
    [self.view addGestureRecognizer:doubleTap];
    
    // Pan gesture
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    
    // Pinch gesture
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
    
    // Rotation gesture
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    rotation.delegate = self;
    [self.view addGestureRecognizer:rotation];
    
    // Set up gesture dependencies - single tap should wait for double tap to fail
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [singleTap requireGestureRecognizerToFail:pan];
    [singleTap requireGestureRecognizerToFail:pinch];
    [singleTap requireGestureRecognizerToFail:rotation];
}

#pragma mark - Gesture Handlers

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.view];
    IBgfxiOSApp *app = BgfxiOSAppLauncher::instance().getApp();
    if (app) {
        app->handleSingleTap(location.x, location.y);
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.view];
    IBgfxiOSApp *app = BgfxiOSAppLauncher::instance().getApp();
    if (app) {
        app->handleDoubleTap(location.x, location.y);
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.view];
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint velocity = [recognizer velocityInView:self.view];
    NSUInteger numTouches = [recognizer numberOfTouches];
    
    IBgfxiOSApp *app = BgfxiOSAppLauncher::instance().getApp();
    if (app) {
        app->handlePan(location.x, location.y, translation.x, translation.y, velocity.x, velocity.y, (int)numTouches);
    }
    
    [recognizer setTranslation:CGPointZero inView:self.view];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.view];
    IBgfxiOSApp *app = BgfxiOSAppLauncher::instance().getApp();
    if (app) {
        app->handlePinch(location.x, location.y, recognizer.scale);
    }
    recognizer.scale = 1.0;
}

- (void)handleRotation:(UIRotationGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.view];
    IBgfxiOSApp *app = BgfxiOSAppLauncher::instance().getApp();
    if (app) {
        app->handleRotation(location.x, location.y, recognizer.rotation);
    }
    recognizer.rotation = 0.0;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // Allow pinch and rotation to work together
    if (([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]) ||
        ([gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]])) {
        return YES;
    }
    return NO;
}

#pragma mark - Keyboard and Mouse Handlers

- (void)handlePointerPan:(UIPanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.view];
    
    IBgfxiOSApp *app = BgfxiOSAppLauncher::instance().getApp();
    if (app) {
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            app->handleMouseDown(location.x, location.y, 0); // Left mouse button
        } else if (recognizer.state == UIGestureRecognizerStateEnded || 
                   recognizer.state == UIGestureRecognizerStateCancelled) {
            app->handleMouseUp(location.x, location.y, 0); // Left mouse button
        } else if (recognizer.state == UIGestureRecognizerStateChanged) {
            app->handleMouseMove(location.x, location.y);
        }
    }
}

- (void)handleHover:(UIHoverGestureRecognizer *)recognizer API_AVAILABLE(ios(13.0)) {
    CGPoint location = [recognizer locationInView:self.view];
    
    IBgfxiOSApp *app = BgfxiOSAppLauncher::instance().getApp();
    if (app) {
        app->handleMouseMove(location.x, location.y);
    }
}

// Override to handle keyboard input
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)pressesBegan:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    for (UIPress *press in presses) {
        UIKey *key = press.key;
        if (key) {
            IBgfxiOSApp *app = BgfxiOSAppLauncher::instance().getApp();
            if (app) {
                app->handleKeyDown((int)key.keyCode);
            }
        }
    }
    [super pressesBegan:presses withEvent:event];
}

- (void)pressesEnded:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    for (UIPress *press in presses) {
        UIKey *key = press.key;
        if (key) {
            IBgfxiOSApp *app = BgfxiOSAppLauncher::instance().getApp();
            if (app) {
                app->handleKeyUp((int)key.keyCode);
            }
        }
    }
    [super pressesEnded:presses withEvent:event];
}

// Override to handle scroll events as mouse wheel
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (@available(iOS 13.4, *)) {
        CGPoint contentOffset = scrollView.contentOffset;
        IBgfxiOSApp *app = BgfxiOSAppLauncher::instance().getApp();
        if (app) {
            // Convert scroll offset to wheel delta
            app->handleMouseWheel(0, 0, contentOffset.x, contentOffset.y);
        }
    }
}


- (NSString*)getUserDocumentsPath:(NSString*)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:filename];
}

- (NSString*)getCachePath:(NSString*)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    return [cachesDirectory stringByAppendingPathComponent:filename];
}

// For truly temporary files
- (NSString*)getTempPath:(NSString*)filename {
    NSString *tmpDirectory = NSTemporaryDirectory();
    return [tmpDirectory stringByAppendingPathComponent:filename];
}

#pragma mark UIImagePickerControllerDelegate


//-(NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)x andY:(int)y count:(int)count
//{
//    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
//
//    // First get the image into your data buffer
//    CGImageRef imageRef = [image CGImage];
//    NSUInteger width = CGImageGetWidth(imageRef);
//    NSUInteger height = CGImageGetHeight(imageRef);
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
//    NSUInteger bytesPerPixel = 4;
//    NSUInteger bytesPerRow = bytesPerPixel * width;
//    NSUInteger bitsPerComponent = 8;
//    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
//                    bitsPerComponent, bytesPerRow, colorSpace,
//                    kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//    CGColorSpaceRelease(colorSpace);
//
//    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
//    CGContextRelease(context);
//
//    // Now your rawData contains the image data in the RGBA8888 pixel format.
//    NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
//    for (int i = 0 ; i < count ; ++i)
//    {
//        CGFloat alpha = ((CGFloat) rawData[byteIndex + 3] ) / 255.0f;
//        CGFloat red   = ((CGFloat) rawData[byteIndex]     ) / alpha;
//        CGFloat green = ((CGFloat) rawData[byteIndex + 1] ) / alpha;
//        CGFloat blue  = ((CGFloat) rawData[byteIndex + 2] ) / alpha;
//        byteIndex += bytesPerPixel;
//
//        UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
//        [result addObject:acolor];
//    }
//
//  free(rawData);
//
//  return result;
//}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // Get the selected image - prefer edited if available, otherwise original
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
    if (!selectedImage) {
        selectedImage = info[UIImagePickerControllerOriginalImage];
    }
    
    if (selectedImage) {
        [self processSelectedImage:selectedImage];
    }
}

- (void)processSelectedImage:(UIImage *)image {
    if (!image) {
        NSLog(@"Warning: No image to process");
        return;
    }
    
    // Extract pixel data from the image
    // Reference: https://stackoverflow.com/questions/448125/how-to-get-pixel-data-from-a-uiimage-cocoa-touch-or-cgimage-core-graphics
    // Get image dimensions
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    // Allocate buffer for pixel data if needed
    NSUInteger requiredSize = height * width * 4; // RGBA
    if (_imageRawDataSize != requiredSize || !_imageRawData) {
        _imageRawDataSize = requiredSize;
        _imageRawData.reset(new uint8_t[_imageRawDataSize]);
    }
    
    // Create bitmap context to extract pixel data
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(
        _imageRawData.get(),
        width, height,
        bitsPerComponent, bytesPerRow, colorSpace,
        kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big
    );
    
    if (context) {
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGContextRelease(context);
        
        // Pass the pixel data to the app
#ifdef ENABLE_CAMERA
        IBgfxiOSApp *app = BgfxiOSAppLauncher::instance().getApp();
        if (app) {
            app->setPickedImage(_imageRawData.get(), width, height, bytesPerPixel);
        }
#endif
    } else {
        NSLog(@"Error: Failed to create bitmap context for image processing");
    }
    
    CGColorSpaceRelease(colorSpace);
       
    //[self.photos addObject:image];
    //[self.collectionView reloadData];

    [self dismissViewControllerAnimated:YES completion:^{
       NSLog(@"Finished image picking");
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

/*
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    
    NSLog (@"Finish image picking");
    
    UIImage *image= info[UIImagePickerControllerEditedImage];
    if (!image) image = info[UIImagePickerControllerOriginalImage];
        
    [self.photos addObject:image];
        
    [self.collectionView reloadData];

    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Finished image picking");
    }];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    
    NSLog (@"Image picker cancelled");
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Image picker view dismissed");
    }];
}
 
 ///------
 
 //must conform to both UIImagePickerControllerDelegate and UINavigationControllerDelegate
 //but don’t have to implement any of the UINavigationControllerDelegate methods.
 - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
 {
     if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
     
     _image = info[UIImagePickerControllerEditedImage];
     [self showImage:_image];
     
     [self dismissViewControllerAnimated:YES completion:nil];
 }



 - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
 {
     if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
     
     [self dismissViewControllerAnimated:YES completion:nil];
 }
 
 
 //*/

//- (void)ImageCropViewControllerDidCancel:(UIViewController *)controller {
//
//}
//
//- (void)ImageCropViewControllerSuccess:(UIViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage {
//    //image = croppedImage;
//    //imageView.image = croppedImage;
//    //CGRect cropArea = controller.cropArea;
//    //[[self navigationController] popViewControllerAnimated:YES];
//}

/*
- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    <#code#>
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
    <#code#>
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    <#code#>
}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    <#code#>
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    <#code#>
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    <#code#>
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    <#code#>
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
    <#code#>
}

- (void)setNeedsFocusUpdate {
    <#code#>
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
    <#code#>
}

- (void)updateFocusIfNeeded {
    <#code#>
}
 */

@end
