//
//  AccelerateProtocol.m
//  QRColourfull
//
//  Created by Kian Davoudi-Rad on 2016-05-25.
//  Copyright © 2016 Kian Davoudi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sampleProtocolAVFoun.h"
#import "AccelerateProtocol.h"

@interface AccelerateProtocol()
{
    IBOutlet UILabel *xlabel;
    IBOutlet UILabel *ylabel;
    IBOutlet UILabel *zlabel;
    
}
@end



@implementation AccelerateProtocol : NSObject

#pragma mark sampleProtocolAVFounDelegateSampleFunction
-(void)startSampleProcess{
     [[UIAccelerometer sharedAccelerometer]setDelegate:self];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate: (UIAcceleration *)acceleration{
    [xlabel setText:[NSString stringWithFormat:@"%f",acceleration.x]];
    [ylabel setText:[NSString stringWithFormat:@"%f",acceleration.y]];
    [zlabel setText:[NSString stringWithFormat:@"%f",acceleration.z]];
}

@end