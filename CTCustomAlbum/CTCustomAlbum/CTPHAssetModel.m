//
//  AlbumModel.m
//
//  Created by chenteng on 2017/12/4.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "CTPHAssetModel.h"

@implementation CTPHAssetModel

+ (instancetype)initWithAsset:(PHAsset *)asset {
    return [[self alloc] initWithAsset:asset];
}
- (instancetype)initWithAsset:(PHAsset *)asset {
    self = [super init];
    if (self) {
        _asset = asset;
        _photoName =  [asset valueForKey:@"filename"];
    }
    return self;
}

- (void)downLoadImageFromiCloud:(dispatch_block_t)block {
    if (self.downloading||self.originImg) {
        return;
    }
    WEAKSELF;
    self.downloading = YES;
    [self.asset fetchPreviewImageComplete:^(UIImage * _Nullable thumbImg, NSDictionary * _Nullable info) {
        //判断是否为原图
        BOOL imgDegrade = [info[PHImageResultIsDegradedKey] boolValue];
        weakSelf.originImg = !imgDegrade;
        if (!imgDegrade) {
            weakSelf.downloading = NO;
            if (block) {
                block();
            }
        }
    }];
}
@end
