//
//  AccelerateProtocol.h
//  QRColourfull
//
//  Created by Kian Davoudi-Rad on 2016-05-25.
//  Copyright © 2016 Kian Davoudi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
// Protocol definition starts here
@protocol AccelerateProtocol <UIAccelerometerDelegate>

@required
- (void) processCompleted;
@end
// Protocol Definition ends here
@interface AccelerateProtocol : NSObject

{
    // Delegate to respond back
    id <AccelerateProtocol> _delegate;
    
}
@property (nonatomic,strong) id delegate;

-(void)startSampleProcess; // Instance method

@end