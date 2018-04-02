//
//  sampleProtocol.h
//  QRColourfull
//
//  Created by Kian Davoudi-Rad on 2016-05-24.
//  Copyright © 2016 Kian Davoudi. All rights reserved.
//

#import <Foundation/Foundation.h>
// Protocol definition starts here
@protocol sampleProtocolDelegate <NSObject>

@required
- (void) processCompleted;
@end
// Protocol Definition ends here
@interface sampleProtocol : NSObject

{
    // Delegate to respond back
    id <sampleProtocolDelegate> _delegate;
    
}
@property (nonatomic,strong) id delegate;

-(void)startSampleProcess; // Instance method

@end