//
//  customAVFoudDevice.h
//  QRColourfull
//
//  Created by Kian Davoudi-Rad on 2016-05-25.
//  Copyright © 2016 Kian Davoudi. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
// Protocol definition starts here
@protocol sampleProtocolAVFounDelegate <NSObject>



@required


@end

// Protocol Definition ends here

@interface sampleProtocolAVFoun : UIView

//{
//    // Delegate to respond back
//    id <sampleProtocolAVFounDelegate> _delegate;
//
//}

@property (nonatomic,strong) id <sampleProtocolAVFounDelegate> delegate;

// Public

// This method should be implemented on the refferee
- (void) didReadCode:(NSString*)code;
- (void) startSampleProcess; // Instance method
- (void) setMetadataObjectTypes:(NSArray *)metaDataObjectTypes;
- (void) start;
- (void) stop;
- (void) updateString :(UIView*) mainView;
- (void) buildNewImageFromBufferForColourDetection: (UIImage*)bufferImage decodedString: (NSString*)decodedQRMessage;
- (void) processCompleted:(NSString*)TestString;
- (void)TakeScreenshotAndSaveToPhotoAlbum;
- (UIImage*)screenshot;
- (void) settapLocation:(CGPoint) taplocation;
- (void) printStringOnScreen: (NSString*) decodedMessage;
-(void)callBackDelegateToStartAgainUIbutton;




@end
