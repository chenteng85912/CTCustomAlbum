//
//  CTPhotosConfiguration.m
//
//  Created by chenteng on 2017/12/12.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import "CTPhotosConfiguration.h"
#import <Photos/Photos.h>

@implementation CTPhotosConfiguration

//外部可配置选项
static NSInteger kMaxNum = 9;//最大选择数量
static NSInteger kShowVideo = 0;//显示视频内容
static NSInteger kChooseHead = 0;//选择头像模式
static NSInteger kOneChoose = 0;//单选模式
static CGFloat kCTPhotosScale = 0.5;//图片压缩比例

+ (NSArray <NSNumber *> *)groupNamesConfig {
    NSMutableArray <NSNumber *> *group = [NSMutableArray new];
    NSArray *groupArray = @[@(PHAssetCollectionSubtypeSmartAlbumPanoramas),     //全景照片
                            @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded), //最近添加
                            @(PHAssetCollectionSubtypeSmartAlbumBursts),        //连拍快照
                            @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),   //相册
                            ];
    [group addObjectsFromArray:groupArray];
    if (kShowVideo) {
        [group addObject:@(PHAssetCollectionSubtypeSmartAlbumVideos)];//视频
    }
    if (@available(iOS 9.0, *)) {
        [group addObject:@(PHAssetCollectionSubtypeSmartAlbumSelfPortraits)];   //自拍
        [group addObject:@(PHAssetCollectionSubtypeSmartAlbumScreenshots)];     //屏幕快照
    }
    return group;
}
+ (CGFloat)outputPhotosScale {
    return  kCTPhotosScale;
}
+ (NSInteger)maxNum {
    return  kMaxNum;
}
+ (BOOL)chooseHead {
    return kChooseHead;
}
+ (BOOL)showVideo {
    return kShowVideo;
}
+ (BOOL)oneChoose {
    return kOneChoose;
}
+ (void)setPhotosScale:(CGFloat)scale maxNum:(NSInteger)maxNum {
    if (scale>0) {
        kCTPhotosScale = scale;
    }
    if (maxNum>0) {
        kMaxNum = maxNum;
    }
}
+ (void)setChooseHead:(BOOL)chooseHead {
    kChooseHead = chooseHead;
}
+ (void)setOneChoose:(BOOL)single {
    kOneChoose = single;
}
+ (void)setVideoShow:(BOOL)showVideo {
    kShowVideo = showVideo;
}

@end
