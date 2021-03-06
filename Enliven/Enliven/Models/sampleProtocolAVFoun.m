//
//  cusProtocolAVFoun.m
//  QRColourfull
//
//  Created by Kian Davoudi-Rad on 2016-05-25.
//  Copyright © 2016 Kian Davoudi. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "sampleProtocolAVFoun.h"
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "ModelQRManagerProtocol.h"


@interface sampleProtocolAVFoun () <AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,ModelQRManagerProtocolDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) NSDate *lastDetectionDate;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) ModelQRManagerProtocol *QRManagerProtocol;
@property (nonatomic, strong) AVCaptureDevice *avCaptureDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *avCaptureDeviceInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *avCaptureVideoDataOutput;
@property (nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong) dispatch_queue_t audioDataOutputQueue;
@property (nonatomic, strong) UIImage *realtimeUIImageFromCaptureOutputDelegateMethod;
@property (nonatomic, strong) NSString *qRDecodedString;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic,strong) UIColor *detectedColour;
@property (nonatomic, strong) UIImage *realtimeUIIMageFromMainView;
@property (nonatomic, strong) UIButton *StartAgainbutton;
@property (nonatomic, strong) NSString *PDF417String;





@end


@implementation sampleProtocolAVFoun :UIView
BOOL isScanningInProgress = true;

CGPoint gcTapLocation;


#pragma Initialization
// Init Implementation delegate method (May25th2016)
- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.initializeAVFoundationDeviceInputOutPut;
        self.AddNewCaptureVideoPreviewLayer;
        self.InitializeMetadataOutput;
        self.QRManagerProtocol = [[ModelQRManagerProtocol alloc] init];
    }
    return self;
}
- (void) start {
    //    if (!_scanning) {
    //        _scanning = YES;
    //     [self.matchView reset];
    [self.captureSession startRunning];
    
    
    //        if ([self.delegate respondsToSelector:@selector(scannerViewDidStartScanning:)]) {
    //            [self.delegate scannerViewDidStartScanning:self];
    //        }
    //n    }
    
}
- (void) stop {
    //    if (_scanning) {
    //        _scanning = NO;
    //        [_timer invalidate];
    //        _timer = nil;
    [self.captureSession stopRunning];
    //
    //        if ([self.delegate respondsToSelector:@selector(scannerViewDidStopScanning:)]) {
    //            [self.delegate scannerViewDidStopScanning:self];
    //        }
    //    }
}
- (void) layoutSubviews {
    // Delegate Method us being updated constantly.
    [super layoutSubviews];
    self.previewLayer.frame = self.bounds;
}
#pragma Initalize davice input/output/UIImage Delgature buffer
// May27th201 initalize davice input/output/UIImage Delgature buffer
- (void) initializeAVFoundationDeviceInputOutPut{
    
    NSError *error;
    
    // Initialization code
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    
    _avCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _avCaptureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_avCaptureDevice error:&error];
    
    
    if ([_avCaptureDevice lockForConfiguration:&error]) {
        if (_avCaptureDevice.isAutoFocusRangeRestrictionSupported) {
            [_avCaptureDevice setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNear];
        }
        if ([_avCaptureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [_avCaptureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        [_avCaptureDevice unlockForConfiguration];
    } else {
        NSLog(@"Could not configure video capture device: %@", error);
    }
    

    _avCaptureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    if ([self.captureSession canAddOutput:_avCaptureVideoDataOutput] ) {
        [self.captureSession addOutput:_avCaptureVideoDataOutput];
        NSDictionary *newSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
        self.avCaptureVideoDataOutput.videoSettings = newSettings;
        
        // discard if the data output queue is blocked (as we process the still image
        [self.avCaptureVideoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
        _videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        [self.avCaptureVideoDataOutput setSampleBufferDelegate:self queue:_videoDataOutputQueue];
        
    if ([self.captureSession canAddInput:_avCaptureDeviceInput])
        [self.captureSession addInput:_avCaptureDeviceInput];
    }
}
- (void) InitializeMetadataOutput{
    
    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:self.metadataOutput];
    [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //[self setMetadataObjectTypes:@[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypePDF417Code]];
    [self setMetadataObjectTypes:@[AVMetadataObjectTypePDF417Code]];

}
- (void) AddNewCaptureVideoPreviewLayer{

self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
[self.layer addSublayer:self.previewLayer];

}

#pragma setLocalVariables
// set local variable from the delegate method (May25,2016)
- (void) setMetadataObjectTypes:(NSArray *)metaDataObjectTypes {
    [self.metadataOutput setMetadataObjectTypes:metaDataObjectTypes];
}

#pragma mark sampleProtocolAVFounDelegateSampleFunction
- (void) startSampleProcess{
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self.delegate
                                   selector:@selector(processCompleted) userInfo:nil repeats:NO];
}
- (CGPoint) pointFromArray:(NSArray *)points atIndex:(NSUInteger)index{NSDictionary *dict = [points objectAtIndex:index];
    CGPoint point;
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)dict, &point);
    return [self.QRManagerProtocol convertPoint:point fromView:self];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
       // Delegate method is being called.
    for(AVMetadataObject *metadataObject in metadataObjects)
    {
        [self TakeScreenshotAndSaveToPhotoAlbum];
        if ([metadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            AVMetadataMachineReadableCodeObject *readableObject = (AVMetadataMachineReadableCodeObject *)[self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
            BOOL foundMatch = readableObject.stringValue != nil;
            _qRDecodedString = readableObject.stringValue;
            
            
            
            //_label.text = _qRDecodedString;
            //[self  printStringOnScreen: readableObject.stringValue];
            [self  printStringOnScreen: [self decodePDF417:readableObject.stringValue]];
            NSLog(@"%@",_qRDecodedString);
            NSArray *corners = readableObject.corners;
            
            if (corners.count == 4 && foundMatch) {
                
                CGPoint topLeftPoint     = [self pointFromArray:corners atIndex:0];
                CGPoint bottomLeftPoint  = [self pointFromArray:corners atIndex:1];
                CGPoint bottomRightPoint = [self pointFromArray:corners atIndex:2];
                CGPoint topRightPoint    = [self pointFromArray:corners atIndex:3];
                

                
                [self captureViewImage: _mainView];
                
                [self.QRManagerProtocol setFoundMatchWithTopLeftPoint:topLeftPoint
                                                topRightPoint:topRightPoint
                                              bottomLeftPoint:bottomLeftPoint
                                             bottomRightPoint:bottomRightPoint
                                                  bufferImage:(UIImage*)_realtimeUIImageFromCaptureOutputDelegateMethod
                                             decodedQRMessage: (NSString*)_qRDecodedString
                 
                 ];
                
            }
        }
    }
}

#pragma mark - Protocol AVCaptureVideoDataOutputSampleBufferDelegate
// Delegate routine that is called when a sample buffer was written
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
//    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
    connection.videoOrientation = _previewLayer.connection.videoOrientation;

    NSLog(@"Delegate routine that is called when a sample buffer was written");
    _realtimeUIImageFromCaptureOutputDelegateMethod = [self imageFromSampleBuffer:sampleBuffer];
    
    
}

// Create a UIImage from sample buffer data
- (UIImage*) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

#pragma mark - Encapsulation - Getters
// GetBuffredImage encapsulation
- (UIImage*) getrealtimeUIImageFromCaptureOutputDelegateMethod{
    
    UIImage *retrunObject = nil;
    
    if (_realtimeUIImageFromCaptureOutputDelegateMethod)
    retrunObject =  _realtimeUIImageFromCaptureOutputDelegateMethod;

    return retrunObject;
}
- (void) updateString :(UIView*) mainViewFromController {
    _mainView = mainViewFromController;
    [_label setFrame:UIScreen.mainScreen.bounds];
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    _label.backgroundColor = [UIColor clearColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = [UIColor colorWithCIColor:[[CIColor alloc]initWithRed:0.0 green:0.0 blue:0.0]];
    _label.numberOfLines = 3;
    _label.lineBreakMode = UILineBreakModeWordWrap;
    _label.adjustsFontSizeToFitWidth;
    _label.text = @"";
    [self initStartAgainbutton:_mainView];
    [_mainView addSubview:_label];
}
-(void)TakeScreenshotAndSaveToPhotoAlbum {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(window.bounds.size);
    
    [_mainView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}
- (UIImage *)imageByRenderingView {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    
    // old style [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (UIImage*)captureViewImage:(UIView *)view {
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
- (UIImage*)screenshot{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot imagesa
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}
-(void)buildAButton{
//    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    aButton.frame = CGRectMake(10,20,200,30);
//    [aButton setTitle:@"TEST    BUTTON" forState:UIControlStateNormal];
//    [aButton addTarget:self action:@selector(yourFunction) forControlEvents:UIControlEventTouchUpInside];
//    [sampleProtocolAVFoun addSubview:aButton];
};

- (UIColor *)colorAtPixel:(CGPoint)point inImage:(UIImage *)image {
    
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), point)) {
        return nil;
    }
    
    // Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = image.CGImage;
    NSUInteger width = image.size.width;
    NSUInteger height = image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData, 1, 1, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


- (void) settapLocation:(CGPoint) taplocation{
    gcTapLocation =taplocation;

                _label.textColor =  [self colorAtPixel:gcTapLocation inImage:_realtimeUIImageFromCaptureOutputDelegateMethod];
    
    
    
    _label.text = @"UPDATING COLOUR .....";
    

};
- (void) printStringOnScreen: (NSString*) decodedMessage{

    if (isScanningInProgress == YES){
        
        _StartAgainbutton.enabled = YES;
        _StartAgainbutton.hidden = NO;
        isScanningInProgress = NO;
        [self stop];
    }
  
        [UIView transitionWithView:_mainView
                          duration:2.0
                           options:UIViewAnimationOptionTransitionNone
                        animations:^{
                           // [_mainView removeFromSuperview]; [containerView addSubview:toView];
                            
                            [_label setFrame:UIScreen.mainScreen.bounds];
                            
                            //_label.bounds = [UIScreen mainScreen].applicationFrame;
                            _label.backgroundColor = [UIColor whiteColor];
                            _label.textAlignment = NSTextAlignmentCenter;
                            _label.textColor = [UIColor colorWithCIColor:[[CIColor alloc]initWithRed:0.0 green:0.0 blue:0.0]];
                            _label.numberOfLines = 20;
                            //_label.lineBreakMode = UILineBreakModeWordWrap;
                            //_label.adjustsFontSizeToFitWidth;
                            _label.text = decodedMessage;
                            //[_mainView addSubview:_label];
                            
                        }
                        completion:^(BOOL complete){
                            [_mainView bringSubviewToFront:_StartAgainbutton];
                            _StartAgainbutton.enabled = YES;
                            _label.backgroundColor = [UIColor clearColor];
                            _label.textAlignment = NSTextAlignmentCenter;
                            _label.textColor = [UIColor colorWithCIColor:[[CIColor alloc]initWithRed:0.0 green:0.0 blue:0.0]];
                            _label.numberOfLines = 3;
                            _label.lineBreakMode = UILineBreakModeWordWrap;
                            _label.adjustsFontSizeToFitWidth;
                            _label.text = decodedMessage;
                            _label.backgroundColor = [UIColor whiteColor];
                            
                            
                        }];
    
    
    
    
    //[self start];
    
}

-(void)callBackDelegateToStartAgainUIbutton:(id)sender{
    
    
    if (isScanningInProgress == NO){
        _label.backgroundColor = [UIColor clearColor];
        _label.text = @" SCANNING ...";
        _StartAgainbutton.enabled = NO;
        _StartAgainbutton.hidden = YES;
        isScanningInProgress = YES;
        [self start];
    }
    
}
-(void)initStartAgainbutton:(UIView*)incomingViewToBeAttachedTo{
    
    _StartAgainbutton= [UIButton buttonWithType:UIButtonTypeCustom];
    _StartAgainbutton.hidden = YES;
    [_StartAgainbutton addTarget:self
                          action:@selector(callBackDelegateToStartAgainUIbutton:)
     forControlEvents:UIControlEventTouchUpInside];
    [_StartAgainbutton setTitle:@"Scan again" forState:UIControlStateNormal];
    _StartAgainbutton.backgroundColor = [UIColor blueColor];
    [_StartAgainbutton setTintColor:[UIColor blackColor]];
    _StartAgainbutton.frame = CGRectMake((UIScreen.mainScreen.bounds.size.width/2.0)-((UIScreen.mainScreen.bounds.size.width/4.0))/2, (UIScreen.mainScreen.bounds.size.width/4.0), (UIScreen.mainScreen.bounds.size.width/4.0), 40.0);
    _StartAgainbutton.enabled = NO;
    [incomingViewToBeAttachedTo addSubview:_StartAgainbutton];
    
}

-(NSString*)decodePDF417:(NSString*)barcodeString{
    

    char *barcodeRaw = [barcodeString cString];
    
//    char barcodeRaw[] = "%BCNORTH VANCOUVDAVOUDI RAD,$KIAN^101-126 12TH ST E$NORTH VANCOUVER BC  V7L 2J5^?;6360289444385=230419860426=?_%0AV7L2J5                     M173 65BRNBRN9769626274                74($^*8QNLM?";
    IDByteArray *byteArray =(IDByteArray*)malloc(sizeof(IDByteArray));
    IDByte *idByte;// = (IDByte*)malloc(sizeof(IDByte));
    IDByteLength  *idByteLength = (IDByteLength*)malloc(sizeof(IDByteLength));
    idByte = returnLenOfString(barcodeRaw, Country, idByteLength);
    byteArray->byteCountry = *idByte;
    idByte = returnLenOfString(barcodeRaw, Province, idByteLength);
    byteArray->byteProvince = *idByte;
    idByte = returnLenOfString(barcodeRaw, City, idByteLength);
    byteArray->byteCity = *idByte;
    idByte = returnLenOfString(barcodeRaw, LastName, idByteLength);
    byteArray->byteLastName = *idByte;
    idByte = returnLenOfString(barcodeRaw, FirstName, idByteLength);
    byteArray->byteFirstName = *idByte;
    idByte = returnLenOfString(barcodeRaw, AddressLineOne, idByteLength);
    byteArray->byteAddressLineOne = *idByte;
    
    
    
    printf("Country Is Canada:\t");
    
    char *stringCountry = (char*)malloc(sizeof(char)*byteArray->byteCountry.len);
    for (int i = 0; i < byteArray->byteCountry.len; i++)
    {
        stringCountry[i] = byteArray->byteCountry.prtStart[i];
        printf("%c", stringCountry[i]);
    }
    printf("\n");
    
    
    printf("Province Is:\t");
    char *stringProvince = (char*)malloc(sizeof(char)*byteArray->byteProvince.len);
    for (int i = 0; i < byteArray->byteProvince.len; i++)
    {
        stringProvince[i] = byteArray->byteProvince.prtStart[i];
        printf("%c", stringProvince[i]);
    }
    printf("\n");
    
    printf("City Is:\t");
    char *stringCity = (char*)malloc(sizeof(char)*byteArray->byteCity.len);
    for (int i = 0; i < byteArray->byteCity.len; i++)
    {
        stringCity[i] = byteArray->byteCity.prtStart[i];
        printf("%c", stringCity[i]);
    }
    printf("\n");
    printf("FirstName Is:\t");
    char *stringFirstName = (char*)malloc(sizeof(char)*byteArray->byteFirstName.len);
    for (int i = 0; i < byteArray->byteFirstName.len; i++)
    {
        stringFirstName[i] = byteArray->byteFirstName.prtStart[i];
        printf("%c", stringFirstName[i]);
    }
    printf("\n");
    
    printf("LastName Is:\t");
    char *stringLastName = (char*)malloc(sizeof(char)*byteArray->byteLastName.len);
    for (int i = 0; i < byteArray->byteLastName.len; i++)
    {
        stringLastName[i] = byteArray->byteLastName.prtStart[i];
        printf("%c", stringLastName[i]);
    }
    printf("\n");
    
    printf("Address on line One:\t");
    char *stringAddressOne = (char*)malloc(sizeof(char)*byteArray->byteAddressLineOne.len);
    for (int i = 0; i < byteArray->byteAddressLineOne.len; i++)
    {
        stringAddressOne[i] = byteArray->byteAddressLineOne.prtStart[i];
        printf("%c", stringAddressOne[i]);
    }
    printf("\n");
    
    
    NSString *NSCountry = [[NSString alloc] initWithUTF8String:stringCountry];
    NSString *NSProvince = [[NSString alloc] initWithUTF8String:stringProvince];
    NSString *NSCity = [[NSString alloc] initWithUTF8String:stringCity];
    NSString *NSFirstName = [[NSString alloc] initWithUTF8String:stringFirstName];
    NSString *NSLastname = [[NSString alloc] initWithUTF8String:stringLastName];
    NSString *NSAddressLineONe = [[NSString alloc] initWithUTF8String:stringAddressOne];
    
    
    
    NSArray *myStrings = [[NSArray alloc] initWithObjects:[NSString stringWithFormat: @"Country = %@ ", NSCountry], [NSString stringWithFormat: @"Province = %@ ", NSProvince], [NSString stringWithFormat: @"City = %@ ", NSCity], [NSString stringWithFormat: @"First Name = %@ ", NSFirstName], [NSString stringWithFormat: @"Last Name = %@ ",NSLastname], [NSString stringWithFormat: @"Address = %@ ", NSAddressLineONe], nil];
    NSString *joinedString = [myStrings componentsJoinedByString:@" "];
    
    
    //NSString *stringCountry = [byteArray->byteCountry.prtStart substringWithRange:NSMakeRange(0, byteArray->byteCountry.len)];
//    NSString *stringProvince = [barcodeString substringWithRange:NSMakeRange(byteArray->byteProvince.prtStart, byteArray->byteProvince.len)];
//    NSString *stringCity = [barcodeString substringWithRange:NSMakeRange(byteArray->byteCity.prtStart, byteArray->byteCity.len)];
//    NSString *stringLastName = [barcodeString substringWithRange:NSMakeRange(byteArray->byteLastName.prtStart, byteArray->byteLastName.len)];
//    NSString *stringFirstName = [barcodeString substringWithRange:NSMakeRange(byteArray->byteFirstName.prtStart, byteArray->byteFirstName.len)];
//    NSString *stringAddressLineOne = [barcodeString substringWithRange:NSMakeRange(byteArray->byteAddressLineOne.prtStart, byteArray->byteAddressLineOne.len)];
//    _PDF417String = barcodeString;
    return joinedString;
    
}



typedef struct IDByte {
    char *prtStart;
    char *prtEnd;
    int len;
}IDByte;

typedef struct IDByteArray{
    IDByte byteCountry;
    IDByte byteProvince;
    IDByte byteCity;
    IDByte byteLastName;
    IDByte byteFirstName;
    IDByte byteAddressLineOne;
    IDByte byteAddressLineTwo;
}IDByteArray;

typedef struct IDByteLength {
    int lenCountry;
    int lenProvince;
    int lenCity;
    int lenLastName;
    int lenFirstName;
    int lenAddressLineOne;
    int lenAddressLineTwo;
}IDByteLength;

enum dataType { Country, Province, City, LastName, FirstName, AddressLineOne, AddressLineTwo };
IDByte *returnLenOfString(char  *prtToHeaderLocation, enum dataType type, IDByteLength  *incomingIdByteLength) {
    
    char *prtH = prtToHeaderLocation;
    IDByte *idByte = (IDByte*) malloc(sizeof(IDByte));
    IDByteLength  *idByteLength = incomingIdByteLength;//(IDByteLength*)malloc(sizeof(IDByteLength));
    int localCounter = 0;
    if (prtToHeaderLocation == NULL)
        return idByte;
    
    
    switch (type)
    {
        case Country:
        {
            localCounter = 0;
            idByte->len = 1;
            idByteLength->lenCountry = idByte->len;
            idByte->prtStart = prtToHeaderLocation + 0;
            idByte->prtEnd = prtToHeaderLocation + 0;
            break;
        }
        case Province:
        {
            int localCounter = 0;
            idByte->len = 2;
            idByte->prtStart = prtToHeaderLocation + 1;
            idByte->prtEnd = prtToHeaderLocation + 2;
            idByteLength->lenProvince = idByte->len;
            break;
        }
        case City:
        {
            localCounter = 0;
            char *prtF = prtToHeaderLocation + idByteLength->lenCountry + idByteLength->lenProvince;
            char *prtS = prtF;
            int localCounter = 0;
            while (*prtF != '^' && (localCounter >= 0 && localCounter < 13))
            {
                localCounter++;
                prtF++;
            }
            
            idByte->len = localCounter;
            idByte->prtStart = prtToHeaderLocation + idByteLength->lenCountry + idByteLength->lenProvince;
            idByte->prtEnd = prtF;
            idByteLength->lenCity = localCounter;
            break;
        }
        case LastName:
        {
            localCounter = 0;
            char *prtF = prtToHeaderLocation + idByteLength->lenCountry + idByteLength->lenProvince + idByteLength->lenCity;
            char *prtS = prtF;
            int localCounter = 0;
            while (*prtF != '$' && (localCounter >= 0 && localCounter<35))
            {
                localCounter++;
                prtF++;
            }
            
            idByte->len = localCounter;
            idByte->prtStart = prtToHeaderLocation + idByteLength->lenCountry + idByteLength->lenProvince + idByteLength->lenCity;
            idByte->prtEnd = prtF;
            idByteLength->lenLastName = localCounter;
            
            break;
        }
        case FirstName:
        {
            localCounter = 0;
            bool x = false;
            char *prtF = prtToHeaderLocation + idByteLength->lenCountry + idByteLength->lenProvince + idByteLength->lenCity +idByteLength->lenLastName;
            if (*prtF == '$') {
                prtF++;
                x = true;
            }
            char const *prtS = prtF;
            int localCounter = 0;
            while (*prtF != '$' &&*prtF != '^' && (localCounter >= 0 && localCounter<(35- idByteLength->lenLastName)))
            {
                localCounter++;
                prtF++;
            }
            
            idByte->len = localCounter;
            if (!x)
                idByte->prtStart = prtToHeaderLocation + idByteLength->lenCountry + idByteLength->lenProvince + idByteLength->lenCity + idByteLength->lenLastName;
            else
                idByte->prtStart = prtToHeaderLocation + idByteLength->lenCountry + idByteLength->lenProvince + idByteLength->lenCity + (idByteLength->lenLastName + 1);
            
            idByte->prtEnd = prtF;
            idByteLength->lenFirstName = localCounter;
            
            break;
        }
        case AddressLineOne:
        {
            localCounter = 0;
            bool x = false;
            char *prtF = prtToHeaderLocation + idByteLength->lenCountry + idByteLength->lenProvince + idByteLength->lenCity + idByteLength->lenLastName + idByteLength->lenFirstName+1;
            if (*prtF == '^') {
                prtF++;
                x = true;
            }
            char const *prtS = prtF;
            int localCounter = 0;
            while (*prtF != '$' &&*prtF != '^' && (localCounter >= 0 && localCounter<(29)))
            {
                localCounter++;
                prtF++;
            }
            
            idByte->len = localCounter;
            if (!x)
                idByte->prtStart = prtToHeaderLocation + idByteLength->lenCountry + idByteLength->lenProvince + idByteLength->lenCity + idByteLength->lenLastName + idByteLength->lenFirstName;//prtToHeaderLocation + idByteLength->lenCountry + idByteLength->lenProvince + idByteLength->lenCity + idByteLength->lenLastName;
            else
                idByte->prtStart = prtToHeaderLocation + idByteLength->lenCountry + idByteLength->lenProvince + idByteLength->lenCity + idByteLength->lenLastName + (idByteLength->lenFirstName +2);//prtToHeaderLocation + idByteLength->lenCountry + idByteLength->lenProvince + idByteLength->lenCity + (idByteLength->lenLastName + 1);
            
            idByte->prtEnd = prtF;
            idByteLength->lenAddressLineOne = localCounter;
            
            break;
        }
        case AddressLineTwo:
            break;
        default:
            break;
    }
    
    return idByte;
    
}
    
    @end
    
