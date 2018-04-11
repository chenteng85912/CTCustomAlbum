//
//  CTPhotosConfiguration.m
//
//  Created by chenteng on 2017/12/12.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import "CTPhotosConfiguration.h"
#import <Photos/Photos.h>

@implementation CTPhotosConfiguration

static NSInteger kMaxNum = 9;
static CGFloat kCTPhotosScale = 0.6;

+ (NSArray <NSNumber *> *)groupNamesConfig{
    
    NSMutableArray <NSNumber *> *group = [NSMutableArray new];
    NSArray *groupArray = @[@(PHAssetCollectionSubtypeSmartAlbumPanoramas),     //全景照片
                            @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded), //最近添加
                            @(PHAssetCollectionSubtypeSmartAlbumBursts),        //连拍快照
                            @(PHAssetCollectionSubtypeSmartAlbumUserLibrary)];  //所有照片
    [group addObjectsFromArray:groupArray];
    if (@available(iOS 9.0, *)) {
        [group addObject:@(PHAssetCollectionSubtypeSmartAlbumSelfPortraits)];   //自拍
        [group addObject:@(PHAssetCollectionSubtypeSmartAlbumScreenshots)];     // 屏幕快照

    }
    return group;
}

+ (CGFloat)outputPhotosScale{
    return  kCTPhotosScale;
}

+ (NSInteger)maxNum{
    return  kMaxNum;
}

+ (void)setPhotosScale:(CGFloat)scale maxNum:(NSInteger)maxNum{
   
    if (scale>0) {
        kCTPhotosScale = scale;
    }
    if (maxNum>0) {
        kMaxNum = maxNum;
    }

}
@end
