//
//  AlbumModel.h
//
//  Created by chenteng on 2017/12/4.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTPhotosConfig.h"
#import "PHAsset+CTPHAssetManager.h"

@interface CTPHAssetModel : NSObject

@property (nonatomic,strong) PHAsset *asset;

@property (nonatomic,strong) NSString *photoName;//图片名称

@property (nonatomic,assign) BOOL selected;//是否选中

@property (nonatomic,assign) BOOL originImg;//是否高质量图片

@property (nonatomic,assign) BOOL downloading;//正在下载

+ (instancetype)initWithAsset:(PHAsset *)asset;


/**
 从iCloud下载图片

 @param block 下载成功回调
 */
- (void)downLoadImageFromiCloud:(dispatch_block_t)block;

@end
