//
//  ModelQRManagerProtocol.m
//  QRColourfull
//
//  Created by Kian Davoudi-Rad on 2016-05-28.
//  Copyright © 2016 Kian Davoudi. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "ModelQRManagerProtocol.h"
#import "MyQRManagedObject.h"

// SingleToneClass

@interface ModelQRManagerProtocol ()

- (void)scannerView:(ModelQRManagerProtocol *)scannerView didReadCode:(NSString*)code;


@property (nonatomic, strong) UIImage* uiimageFromDidOutputSampleBuffer;

@property (nonatomic, strong) MyQRManagedObject* QRModel;

@property (nonatomic, strong) UIColor *matchFoundColor;
@property (nonatomic, strong) UIColor *scanningColor;
@property (nonatomic, assign) CGFloat minMatchBoxHeight;



- (void) PlayBeepOnSuccess;
- (UIImage*) ExtractQRFromUIImage:(UIImage*) uiimageFromDidOutputSampleBuffer;
- (UIColor*) GeUIColourFromUIimageFromDidOutputSampleBuffer:(UIImage*)uiimageFromDidOutputSampleBuffer;
- (UIColor *) colorAtPixel:(CGPoint)point inImage:(UIImage *)image;
- (UIImage *)imageFromLayer:(CALayer *)layer;

@end

@implementation ModelQRManagerProtocol: UIView

// Animation Layer
BOOL _set;
CAShapeLayer *_shapeLayer;
static NSString * const matchAnimationID = @"animateMatch";
static NSString * const scanningAnimationID = @"animateScanning";
static NSString * const flashAnimationID = @"animateFlash";


- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.matchFoundColor = [UIColor redColor];
        self.scanningColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
        
        self.minMatchBoxHeight = 10.0f;
        
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        _shapeLayer.strokeColor = [self.scanningColor CGColor];
        _shapeLayer.lineWidth = 2.0;
        _shapeLayer.fillRule = kCAFillRuleNonZero;
        _shapeLayer.frame = self.bounds;
        [self.layer addSublayer:_shapeLayer];
        
        [self reset];

    }
    return self;
}
- (UIColor *)colorAtPixel:(CGPoint)point inImage:(UIImage *)image {
    
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), point)) {
        return nil;
    }
    
    // Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
    //UIImage *rotatedImage = [originalImage imageRotatedByDegrees:90.0];
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

// http://stackoverflow.com/questions/448125/how-to-get-pixel-data-from-a-uiimage-cocoa-touch-or-cgimage-core-graphics/1262893#1262893
// http://stackoverflow.com/questions/158914/cropping-an-uiimage

- (void)setFoundMatchWithTopLeftPoint:(CGPoint)topLeftPoint topRightPoint:(CGPoint)topRightPoint bottomLeftPoint:(CGPoint)bottomLeftPoint bottomRightPoint:(CGPoint)bottomRightPoint bufferImage:(UIImage*) bufferImage decodedQRMessage:(NSString*) decodedQRMessage{
    NSLog(@"TestUIViewIsRunning");
    NSLog(@"%@",decodedQRMessage);
    
    
//    UIColor * testColour = [self colorAtPixel: topLeftPoint inImage:bufferImage];
//    CGSize testSize = CGSizeMake(100.1, 100.1); //alloc]init];
//    UIImage *testImage =  [self imageWithColor:testColour size:testSize];
//    UIImage * PortraitImage = [self imageRotatedByDegrees: bufferImage deg:90.0];
//    CGRect cropRect = CGRectMake(topLeftPoint.x,topLeftPoint.y,1000,100);
//    CGImageRef imageRef = CGImageCreateWithImageInRect([PortraitImage CGImage], cropRect);
//    // or use the UIImage wherever you like
//    UIImage *TestCopped = [UIImage imageWithCGImage:imageRef];
//    //CGImageRelease(imageRef);
    
    // perform animation too:
    _uiimageFromDidOutputSampleBuffer = bufferImage;
    _decodedString =decodedQRMessage;
    [self setFoundMatchWithTopLeftPoint:topLeftPoint topRightPoint:topRightPoint bottomLeftPoint:bottomLeftPoint bottomRightPoint:bottomRightPoint];


}
- (UIImage*) imageWithColor:(UIColor*)color size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    UIBezierPath* rPath = [UIBezierPath bezierPathWithRect:CGRectMake(0., 0., size.width, size.height)];
    [color setFill];
    [rPath fill];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (void)reset {
    [_shapeLayer removeAllAnimations];
//    _shapeLayer.strokeColor = [self.scanningColor CGColor];
    _set = NO;
    [self setNeedsLayout];
}
- (CGPoint)halfWayPointFromPoint:(CGPoint)point1 andPoint:(CGPoint)point2 {
    return CGPointMake((point1.x + point2.x)/2.0, (point1.y + point2.y)/2.0);
}
- (CGFloat)distanceBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2 {
    CGFloat distance = sqrtf((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y));
    return distance;
}
- (void)extraPolatePoint:(CGPoint *)point1 andPoint:(CGPoint *)point2 {
    CGFloat distance = [self distanceBetweenPoint:*point1 andPoint:*point2];
    CGFloat extraPolateHeight = (self.minMatchBoxHeight - distance)/2.0;
    
    if (extraPolateHeight > 0.0) {
        CGPoint modifiedPoint1 = CGPointMake(((*point1).x - (*point2).x) * extraPolateHeight + (*point1).x, ((*point1).y - (*point2).y) * extraPolateHeight + (*point1).y);
        CGPoint modifiedPoint2 = CGPointMake(((*point2).x - (*point1).x) * extraPolateHeight + (*point2).x, ((*point2).y - (*point1).y) * extraPolateHeight + (*point2).y);
        *point1 = modifiedPoint1;
        *point2 = modifiedPoint2;
    }
}
- (CGPathRef)createPathWithTopLeftPoint:(CGPoint)topLeftPoint topRightPoint:(CGPoint)topRightPoint bottomLeftPoint:(CGPoint)bottomLeftPoint bottomRightPoint:(CGPoint)bottomRightPoint {
    
    [self extraPolatePoint:&topLeftPoint andPoint:&bottomLeftPoint];
    [self extraPolatePoint:&topRightPoint andPoint:&bottomRightPoint];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, topLeftPoint.x, topLeftPoint.y);
    CGPathAddLineToPoint(path, NULL, topRightPoint.x, topRightPoint.y);
    CGPathAddLineToPoint(path, NULL, bottomRightPoint.x, bottomRightPoint.y);
    CGPathAddLineToPoint(path, NULL, bottomLeftPoint.x, bottomLeftPoint.y);
    CGPathCloseSubpath(path);
    
    CGPoint halfPoint = [self halfWayPointFromPoint:topLeftPoint andPoint:topRightPoint];
    CGPathMoveToPoint(path, NULL, halfPoint.x, halfPoint.y);
    CGPathAddLineToPoint(path, NULL, halfPoint.x, halfPoint.y + 5.0);
    
    halfPoint = [self halfWayPointFromPoint:topLeftPoint andPoint:bottomLeftPoint];
    CGPathMoveToPoint(path, NULL, halfPoint.x, halfPoint.y);
    CGPathAddLineToPoint(path, NULL, halfPoint.x + 5.0, halfPoint.y);
    
    halfPoint = [self halfWayPointFromPoint:topRightPoint andPoint:bottomRightPoint];
    CGPathMoveToPoint(path, NULL, halfPoint.x, halfPoint.y);
    CGPathAddLineToPoint(path, NULL, halfPoint.x - 5.0, halfPoint.y);
    
    halfPoint = [self halfWayPointFromPoint:bottomLeftPoint andPoint:bottomRightPoint];
    CGPathMoveToPoint(path, NULL, halfPoint.x, halfPoint.y);
    CGPathAddLineToPoint(path, NULL, halfPoint.x, halfPoint.y - 5.0);
    
    return path;
}
- (void)startScanningAnimating {
    if (![_shapeLayer animationForKey:scanningAnimationID]) {
        [_shapeLayer removeAllAnimations];
        
        CGFloat marginX = 5.0f;
        CGFloat marginY = 25.0f;
        CGPathRef fromPath = [self createPathWithTopLeftPoint:CGPointMake(marginX, marginY)
                                                topRightPoint:CGPointMake(self.bounds.size.width - marginX, marginY)
                                              bottomLeftPoint:CGPointMake(marginX, self.bounds.size.height - marginY)
                                             bottomRightPoint:CGPointMake(self.bounds.size.width - marginX, self.bounds.size.height - marginY)];
        
        
        marginX = 25.0f;
        marginY = 5.0f;
        CGPathRef toPath = [self createPathWithTopLeftPoint:CGPointMake(marginX, marginY)
                                              topRightPoint:CGPointMake(self.bounds.size.width - marginX, marginY)
                                            bottomLeftPoint:CGPointMake(marginX, self.bounds.size.height - marginY)
                                           bottomRightPoint:CGPointMake(self.bounds.size.width - marginX, self.bounds.size.height - marginY)];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.duration = 1.0;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.repeatCount = CGFLOAT_MAX;
        animation.autoreverses = YES;
        animation.fromValue = (__bridge id)fromPath;
        animation.toValue = (__bridge id)toPath;
        [_shapeLayer addAnimation:animation forKey:scanningAnimationID];
        
        CFRelease(fromPath);
        CFRelease(toPath);
    }
}
- (void)animateToMatchWithTopLeftPoint:(CGPoint)topLeftPoint topRightPoint:(CGPoint)topRightPoint bottomLeftPoint:(CGPoint)bottomLeftPoint bottomRightPoint:(CGPoint)bottomRightPoint  {
    if (![_shapeLayer animationForKey:matchAnimationID]) {
        [_shapeLayer removeAllAnimations];
        
        CAShapeLayer *currentLayerState = [_shapeLayer presentationLayer];
        
        CGPathRef toPath = [self createPathWithTopLeftPoint:topLeftPoint
                                              topRightPoint:topRightPoint
                                            bottomLeftPoint:bottomLeftPoint
                                           bottomRightPoint:bottomRightPoint];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.duration = 0.3;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.repeatCount = 1;
        animation.autoreverses = NO;
        animation.fromValue = (__bridge id)currentLayerState.path;
        animation.toValue = (__bridge id)toPath;
        animation.delegate = self;
        _shapeLayer.path = toPath;
        [_shapeLayer addAnimation:animation forKey:matchAnimationID];
        //[self imageFromLayer:_shapeLayer];
        
        CFRelease(toPath);
    }
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        [_shapeLayer removeAllAnimations];
        
        _shapeLayer.strokeColor = [self.matchFoundColor CGColor];
        
        //Flash the stroke color
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
        animation.duration = 0.1;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.repeatCount = 3;
        animation.autoreverses = YES;
        animation.fromValue         = (id) [self.matchFoundColor CGColor];
        animation.toValue           = (id) [self.scanningColor CGColor];
        [_shapeLayer addAnimation:animation forKey:flashAnimationID];
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_set) {
        [self startScanningAnimating];
    }
}
- (void)setFoundMatchWithTopLeftPoint:(CGPoint)topLeftPoint topRightPoint:(CGPoint)topRightPoint bottomLeftPoint:(CGPoint)bottomLeftPoint bottomRightPoint:(CGPoint)bottomRightPoint {
    _set = YES;
    [self animateToMatchWithTopLeftPoint:topLeftPoint topRightPoint:topRightPoint bottomLeftPoint:bottomLeftPoint bottomRightPoint:bottomRightPoint];
}


- (UIImage *)imageFromLayer:(CALayer *)layer
{
    
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, 0);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    _uiimageFromDidOutputSampleBuffer = [self imageRotatedByDegrees:_uiimageFromDidOutputSampleBuffer deg:90];

    layer.contents = (id) _uiimageFromDidOutputSampleBuffer.CGImage;
    return outputImage;
}



@end

