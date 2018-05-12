//
//  PHAssetCollection+CTAssetCollectionManager.m
//
//  Created by chenteng on 2017/12/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "PHAssetCollection+CTAssetCollectionManager.h"
#import <objc/runtime.h>

@implementation PHAssetCollection (CTAssetCollectionManager)

/**
 获取相册基本信息
 
 @param size 获取图片的大小
 @param completeBlock 相册名称，相册照片数量，最新照片缩略图
 */
- (void)fetchCollectionInfoWithSize:(CGSize)size
                          complete:(nonnull void (^)(NSString * _Nonnull title, NSUInteger assetCount, UIImage * _Nullable image))completeBlock {
    
    //获取照片资源
    PHFetchResult * assetResult = [PHAsset fetchAssetsInAssetCollection:self options:nil];
    
    NSUInteger count = [assetResult countOfAssetsWithMediaType:PHAssetMediaTypeImage];
    if (count == 0){
        completeBlock(self.localizedTitle,0,[UIImage new]);
        return;
    }
 
    UIImage * representationImage = objc_getAssociatedObject(self, &@selector(fetchCollectionInfoWithSize:complete:));
    
    if (representationImage){
        completeBlock(self.localizedTitle,count,representationImage);
        return;
    }
    
    //获取屏幕的点
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize newSize = CGSizeMake(size.width * scale, size.height * scale);
    
    //开始截取最新一张照
    [[PHCachingImageManager defaultManager] requestImageForAsset:assetResult.lastObject targetSize:newSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        objc_setAssociatedObject(self, &@selector(fetchCollectionInfoWithSize:complete:), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        //block to trans image
        completeBlock(self.localizedTitle,count,result);
        
    }];
}

- (PHFetchResult *)fetchCollectionAssets {
    return  [PHAsset fetchAssetsInAssetCollection:self options:[[PHFetchOptions alloc]init]];
}
- (void)dealloc {
    objc_setAssociatedObject(self, &@selector(fetchCollectionInfoWithSize:complete:), nil, OBJC_ASSOCIATION_ASSIGN);
    objc_removeAssociatedObjects(self);
}
@end
