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

@property (nonatomic, copy) CTCustomMediasBLock block;

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

+ (instancetype)initWithBlock:(CTCustomMediasBLock)block {
    return [[self alloc] initWithBlock:block];
}

- (instancetype)initWithBlock:(CTCustomMediasBLock)block {
    self = [super init];
    if (self) {
        _block = block;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setBackgroundImage:[UIImage imageFromColor:kColorValue(0xFFFFFF) size:CGSizeMake(kDevice_width, NAVBAR_HEIGHT)] forBarMetrics:UIBarMetricsDefault];

    CTAlbumGroupController *group = [CTAlbumGroupController new];
    group.photoBlock = _block;

    self.viewControllers = @[group];
}

- (void)dealloc {
    [CTPhotosConfiguration setVideoShow:NO];
    [CTPhotosConfiguration setChooseHead:NO];
    [CTPhotosConfiguration setOneChoose:NO];
    [CTPhotosConfiguration setPhotosScale:0.6 maxNum:9];
    NSLog(@"%@ dealloc",self);
}
@end
