//
//  CTPhotosNavigationViewController.m
//
//  Created by chenteng on 2017/12/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "CTPhotosNavigationViewController.h"
#import "CTAlbumGroupController.h"
#import "UIImage+ColorImg.h"

@interface CTPhotosNavigationViewController ()

@property (nonatomic, copy) CTCustomImagesBLock block;

@end

@implementation CTPhotosNavigationViewController

+ (instancetype)initWithDelegate:(id <CTSendPhotosProtocol>)delegate {
    return [[self alloc] initWithDelegate:delegate];
}
- (instancetype)initWithDelegate:(id <CTSendPhotosProtocol>)delegate {
    self = [super init];
    if (self) {
        [CTPhotoManager setDelegate:delegate];
       
    }
    return self;
}
+ (instancetype)initWithDelegate:(id <CTSendPhotosProtocol>)delegate
                      photoScale:(CGFloat)scale
                          maxNum:(NSInteger)maxNum {
    return [[self alloc] initWithDelegate:delegate
                               photoScale:scale
                                   maxNum:maxNum];
}
- (instancetype)initWithDelegate:(id <CTSendPhotosProtocol>)delegate
                      photoScale:(CGFloat)scale
                          maxNum:(NSInteger)maxNum {
    self = [super init];
    if (self) {
        [CTPhotoManager setDelegate:delegate];
        [CTPhotosConfiguration setPhotosScale:scale maxNum:maxNum];
    }
    return self;
}
+ (instancetype)initWithBlock:(CTCustomImagesBLock)block {
    return [[self alloc] initWithBlock:block];
}
+ (instancetype)initWithBlock:(CTCustomImagesBLock)block
                   photoScale:(CGFloat)scale
                       maxNum:(NSInteger)maxNum {
    return [[self alloc] initWithBlock:block photoScale:scale maxNum:maxNum];
}
- (instancetype)initWithBlock:(CTCustomImagesBLock)block
                   photoScale:(CGFloat)scale
                       maxNum:(NSInteger)maxNum {
    self = [super init];
    if (self) {
        _block = block;
        [CTPhotosConfiguration setPhotosScale:scale maxNum:maxNum];
    }
    return self;
}
- (instancetype)initWithBlock:(CTCustomImagesBLock)block {
    self = [super init];
    if (self) {
        _block = block;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setBackgroundImage:[UIImage imageFromColor:[UIColor blackColor] size:CGSizeMake(Device_width, NAVBAR_HEIGHT)] forBarMetrics:UIBarMetricsDefault];

    CTAlbumGroupController *group = [CTAlbumGroupController new];
    group.photoBlock = _block;

    self.viewControllers = @[group];
}

- (void)dealloc {
    NSLog(@"%@ dealloc",self);
}
@end
