//
//  sampleProtocol.m
//  QRColourfull
//
//  Created by Kian Davoudi-Rad on 2016-05-24.
//  Copyright © 2016 Kian Davoudi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SampleProtocol.h"

@implementation sampleProtocol : NSObject

-(void)startSampleProcess{
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self.delegate
                                   selector:@selector(processCompleted) userInfo:nil repeats:NO];
}
@end