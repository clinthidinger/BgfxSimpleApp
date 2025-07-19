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
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    }
    return _indicator;
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
    
     //_imageCropView = [ImageCropView alloc];
    
    // app->setRefeshFunc( [view] () { [view setNeedsDisplay]; } );
    _imageRawDataSize = 0;
    BgfxiOSAppLauncher::instance().getApp()->setShowImagePickerPhotoFunc([self] () {
        [self showImagePickerPhotos];
    });
    BgfxiOSAppLauncher::instance().getApp()->setShowImagePickerCameraFunc([self] () {
        [self showImagePickerCamera];
    });
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



#pragma mark - Input Event Handlers (Forward to Renderer)

- (void)handleKeyDown:(NSInteger)keyCode
{
    //[_pressedKeys addObject:@(keyCode)];
    // Forward to renderer for game logic
    //[self.renderer handleKeyDown:keyCode];
}

- (void)handleKeyUp:(NSInteger)keyCode {
    //[_pressedKeys removeObject:@(keyCode)];
    // Forward to renderer for game logic
    //[self.renderer handleKeyUp:keyCode];
}

- (void)handleMouseDown:(CGPoint)location button:(NSInteger)button
{
    //_mousePressed = YES;
    //_lastMouseLocation = location;
    // Forward to renderer for game logic
    //[self.renderer handleMouseDown:location button:button];
}

- (void)handleMouseUp:(CGPoint)location button:(NSInteger)button
{
    //_mousePressed = NO;
    // Forward to renderer for game logic
    //[self.renderer handleMouseUp:location button:button];
}

- (void)handleMouseDrag:(CGPoint)location
{
    //if (_mousePressed) {
        CGPoint delta = CGPointMake(location.x - _lastMouseLocation.x,
                                   location.y - _lastMouseLocation.y);
        _lastMouseLocation = location;
        // Forward to renderer for game logic
        //[self.renderer handleMouseDrag:location delta:delta];
    //}
}

- (void)handleMouseWheel:(CGFloat)deltaX deltaY:(CGFloat)deltaY
{
    // Forward to renderer for game logic
    //[self.renderer handleMouseWheel:deltaX deltaY:deltaY];
}

- (CGFloat)getWidth
{
    return self.mtkView.bounds.size.width;
}

- (CGFloat)getHeight
{
    return self.mtkView.bounds.size.height;
}

- (void)setSize:(CGFloat)width height:(CGFloat)height
{
    CGRect newFrame = CGRectMake(self.mtkView.frame.origin.x,
                                self.mtkView.frame.origin.y,
                                width, height);
    self.mtkView.frame = newFrame;
    
    // Notify renderer of size change
    [self.renderer handleResize:CGSizeMake(width, height)];
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
- (void)showImagePicker: (UIImagePickerControllerSourceType)sourceType
{
    //pick image from picker
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] ) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        //imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //!!!imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage, nil];
        imagePicker.allowsEditing = NO;
        imagePicker.sourceType = sourceType;
        //imagePicker.imageExportPreset
        //imagePicker.cameraFlashMode =  UIImagePickerControllerCameraFlashModeAuto;
        
//        if (sourceType == UIImagePickerControllerSourceTypeCamera) {
//            imagePicker.cameraFlashMode =  UIImagePickerControllerCameraFlashModeAuto;
//        }
        
        
        //imagePicker.allowsEditing = true;// seems to strecth the image or have orientation issues.
        //imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        //imagePicker.
        // Need to reduce size.  Either do in opencv or look at:
        //https://stackoverflow.com/questions/12258280/capturing-photos-with-specific-resolution-using-the-uiimagepickercontroller
        /*
       
         imagePicker.modalPresentationStyle =
             (sourceType == UIImagePickerControllerSourceTypeCamera) ?
        UIModalPresentationFullScreen : UIModalPresentationPopover;
         
        UIPopoverPresentationController *presentationController = imagePicker.popoverPresentationController;
        //presentationController?.barButtonItem = button;     // Display popover from the UIBarButtonItem as an anchor.
        //presentationController?.permittedArrowDirections = UIPopoverArrowDirection.any;
         
         if (sourceType == UIImagePickerControllerSourceTypeCamera) {
             // The user wants to use the camera interface. Set up our custom overlay view for the camera.
             imagePicker.showsCameraControls = false;
         
             // Apply our overlay view containing the toolar to take pictures in various ways.
             //overlayView?.frame = (imagePicker.cameraOverlayView?.frame)!
             //imagePicker.cameraOverlayView = overlayView;
         }
         //*/
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
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

-(void)imagePickerController:(nonnull UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info {
    
//    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
//    [self dismissViewControllerAnimated:YES completion:nil];
//    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
//        UIImage *pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
//
//        self.imageView.image = pickedImage;
//    }
    
    UIImage *image= info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    
    /*
    {
        if(image != nil)
        {
            [self dismissViewControllerAnimated:YES completion:^{
                  NSLog(@"Finished image picking");
               }];
            
            _imageCropView.image = image;
            //_imageCropView.controlColor = [UIColor cyanColor];
        
            ImageCropViewController *controller = [[ImageCropViewController alloc] initWithImage:image];
            controller.delegate = self;
            controller.blurredBackground = YES;
            // set the cropped area
            controller.cropArea = CGRectMake(0, 0, 100, 200);
            //[[self navigationController] pushViewController:controller animated:YES];
            [self presentViewController:controller animated:YES completion:nil];
            return;
        }
    }
     */
    
    
    
    //image.CGImage->
    //NSData *imageData = UIImagePNGRepresentation(image);
    
    /*
    {
        CGImageRef imageRef = [image CGImage];
        CFDataRef dataRef = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));
        const UInt8 *rawData = CFDataGetBytePtr( dataRef );
        BgfxiOSAppLauncher::instance().getApp()->setPickedImage(rawData, image.size.width, image.size.height, 4);
        //std::unique_ptr<uint8_t[]> rawData2(new uint8_t[image.size.width * image.size.height * 4]);
        //CFDataGetBytes( dataRef, CFRangeMake( 0, image.size.width * image.size.height * 4 ), rawData2.get() );
        //BgfxiOSAppLauncher::instance().getApp()->setPickedImage( rawData2.get(), image.size.width, image.size.height, 4);
       
    }
     //*/
    //*
    {
        //https://stackoverflow.com/questions/448125/how-to-get-pixel-data-from-a-uiimage-cocoa-touch-or-cgimage-core-graphics
        
        // todo: https://stackoverflow.com/questions/12258280/capturing-photos-with-specific-resolution-using-the-uiimagepickercontroller
        //auto width = image.size.width;
        //auto height = image.size.height;
        CGImageRef imageRef = [image CGImage];
        // TODO: change width, height to desired image size!!!
        NSUInteger width = CGImageGetWidth(imageRef);
        NSUInteger height = CGImageGetHeight(imageRef);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        //std::unique_ptr<uint8_t[]> rawData( new uint8_t[height * width * 4] ); // Make member!!!
        if( ( _imageRawDataSize != ( height * width * 4 ) ) || ( _imageRawData == nullptr ) )
        {
            _imageRawDataSize = height * width * 4;
            _imageRawData.reset( new uint8_t[_imageRawDataSize] );
        }
        NSUInteger bytesPerPixel = 4;
        NSUInteger bytesPerRow = bytesPerPixel * width;
        NSUInteger bitsPerComponent = 8;
        CGContextRef context = CGBitmapContextCreate(
                        _imageRawData.get(),
                        width, height,
                        bitsPerComponent, bytesPerRow, colorSpace,
                        kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);

        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGContextRelease(context);
        BgfxiOSAppLauncher::instance().getApp()->setPickedImage(_imageRawData.get(), width, height, 4);
    }
     //*/
    
    
    //BgfxiOSAppLauncher::instance().getApp()->setPickedImage(static_cast<const uint8_t *>(imageData.bytes), image.size.width, image.size.height, 4);
       
    //[self.photos addObject:image];
    //[self.collectionView reloadData];

    [self dismissViewControllerAnimated:YES completion:^{
       NSLog(@"Finished image picking");
    }];
}

-(void)imagePickerControllerDidCancel:(nonnull UIImagePickerController *)picker {
    
    //Take the picker away if clicked on cancel
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //[self dismissViewControllerAnimated:YES completion:^{
    //    NSLog(@"Image picker view dismissed");
    //}];
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
