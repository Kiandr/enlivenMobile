//
//  MyQRManagedObject.h
//  QRColourfull
//
//  Created by Kian Davoudi-Rad on 2016-05-28.
//  Copyright © 2016 Kian Davoudi. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface MyQRManagedObject <NSObject>

@property (nonatomic) CGPoint*  topLeftPoint;
@property (nonatomic) CGPoint *  topRightPoint;
@property (nonatomic) CGPoint *  bottomLeftPoint;
@property (nonatomic) CGPoint *  bottomRightPoint;

@end