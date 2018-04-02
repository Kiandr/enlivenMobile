//
//  ModelQRManagerProtocol.m
//  QRColourfull
//
//  Created by Kian Davoudi-Rad on 2016-05-28.
//  Copyright © 2016 Kian Davoudi. All rights reserved.
//



#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@protocol ModelQRManagerProtocolDelegate <NSObject>

@required

@end

@interface ModelQRManagerProtocol : UIView


{
    // Delegate to respond back
    id <ModelQRManagerProtocolDelegate> _delegate;
}

@property (nonatomic,strong) id delegate;

@property (nonatomic, weak) NSString*  decodedString;

- (void)setFoundMatchWithTopLeftPoint:(CGPoint)topLeftPoint topRightPoint:(CGPoint)topRightPoint bottomLeftPoint:(CGPoint)bottomLeftPoint bottomRightPoint:(CGPoint)bottomRightPoint bufferImage:(UIImage*) bufferImage decodedQRMessage:(NSString*)decodedQRMessage;



@end

