//
//  PHAsset+CTPHAssetManager.m
//
//  Created by chenteng on 2017/12/14.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import "PHAsset+CTPHAssetManager.h"
#import <objc/runtime.h>
#import "CTPhotosConfig.h"

@implementation PHAsset (CTPHAssetManager)

- (NSMutableDictionary *)originPhotoSize {
    return objc_getAssociatedObject(self, &@selector(originPhotoSize));
}

- (void)setOriginPhotoSize:(NSMutableDictionary *)newInfo {
    objc_setAssociatedObject(self, &@selector(originPhotoSize), newInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)checkLocalAsset {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.synchronous = YES;
    
    __block BOOL isInLocalAblum = YES;
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:self options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        isInLocalAblum = imageData ? YES : NO;
    }];
    return isInLocalAblum;
}
/**
 获取缩略图

 @param size 图片尺寸
 @param completeBlock block返回
 */
- (void)fetchThumbImageWithSize:(CGSize)size complete:(nonnull void (^)(UIImage * _Nullable img,NSDictionary * _Nullable info))completeBlock {
    __weak typeof(self)copy_self = self;
   
    CGFloat scale = [UIScreen mainScreen].scale;
    [[PHCachingImageManager defaultManager] requestImageForAsset:copy_self targetSize:CGSizeMake(scale*size.width, scale*size.height) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        kDISPATCH_MAIN_THREAD(^{
            completeBlock(result,info);
        });
        
    }];
    
}

/**
 获取原图

 @param completeBlock 返回原图
 */
- (void)fetchOriginImageComplete:(void (^)( UIImage* _Nonnull originImg))completeBlock {

    CGSize  size = CGSizeMake(self.pixelWidth, self.pixelHeight);
    PHImageRequestOptions * option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = YES;

    [[PHCachingImageManager defaultManager] requestImageForAsset:self targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        kDISPATCH_MAIN_THREAD(^{
            //返回原图
            BOOL imgDegrade = [info[PHImageResultIsDegradedKey] boolValue];
            if (!imgDegrade) {
                completeBlock(result);
            }
        });
      
    }];
   
}

/**
 获取原图

 @return 返回原图
 */
- (NSData *_Nullable)fetchOriginImagData {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.synchronous = YES;
    
    __block NSData *imgData;
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:self options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        imgData = imageData;
    }];
    return imgData;
}
/**
 根据size获取缩略图

 @param completeBlock 返回缩略图
 */
- (void)fetchPreviewImageComplete:(nonnull void (^)(UIImage * _Nullable thumbImg,NSDictionary * _Nullable info))completeBlock {

    CGSize newSize = CGSizeMake(self.pixelWidth, self.pixelHeight);
 
    PHImageRequestOptions * option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = YES;

    [[PHCachingImageManager defaultManager] requestImageForAsset:self targetSize:newSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        kDISPATCH_MAIN_THREAD(^{
            completeBlock(result,info);

        });
        
    }];
    
}

/**
 获取原始图片的大小

 */
- (NSNumber * _Nullable)getImageSize {
    
    if (!self.originPhotoSize)
    {
        self.originPhotoSize = [NSMutableDictionary new];
    }
    
    NSString *fileName = [self valueForKey:@"filename"];
    //直接返回大小
    __block NSNumber * sizeRerturn = self.originPhotoSize[fileName];
    if (sizeRerturn) {
      
        return sizeRerturn;
    }
    
    //初始化option选项
    PHImageRequestOptions * option = [[PHImageRequestOptions alloc] init];
    option.synchronous = YES;
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:self options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {

        //将大小传出，默认为btye
        sizeRerturn = [NSNumber numberWithInteger:imageData.length];
        //数组进行缓存
        self.originPhotoSize[fileName] = sizeRerturn;
        //将大小传出，默认为btye
    }];
   
    return sizeRerturn;
}

@end
