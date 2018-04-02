//
//  ViewController.m
//  QRColourfull
//
//  Created by Kian Davoudi-Rad on 2016-05-24.
//  Copyright © 2016 Kian Davoudi. All rights reserved.
//

#import "ViewController.h"
#import "sampleProtocolAVFoun.h"
#import "ModelQRManagerProtocol.h"

@interface ViewController ()<sampleProtocolAVFounDelegate>

@property (nonatomic, strong) sampleProtocolAVFoun *sampleProtocolUIView;
@property (nonatomic, strong) ModelQRManagerProtocol *QRManagerUIView;
//- (void) printStringOnScreen;
- (void)buttonAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.sampleProtocolUIView = [[sampleProtocolAVFoun alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.QRManagerUIView = [[ModelQRManagerProtocol alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    self.sampleProtocolUIView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.sampleProtocolUIView.delegate = self;
    [self.view addSubview:self.sampleProtocolUIView];
    [self.view addSubview:self.QRManagerUIView];
    
    // tap recoggnizer
    
    //The setup code (in viewDidLoad in your view controller)
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    
    
    
    
    
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.sampleProtocolUIView stop];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.sampleProtocolUIView start];
    [self.sampleProtocolUIView updateString:self.view];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) TakeScreenshotAndSaveToPhotoAlbum {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(window.bounds.size);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

- (void) barButtonCustomPressed:(id)sender {
    [self TakeScreenshotAndSaveToPhotoAlbum];
}


//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)tapRecognizer {
    
    
    if(tapRecognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint point = [tapRecognizer locationInView:tapRecognizer.view];
        [self.sampleProtocolUIView settapLocation:point];
    }
    
    //Do stuff here...
    
}

@end

