//
//  AlbumModel.h
//
//  Created by chenteng on 2017/12/4.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTPhotosConfig.h"
#import "PHAsset+CTPHAssetManager.h"

@protocol CTPHAssetModelDelegate <NSObject>

@optional
- (void)downloadMedia:(double)progress;
- (void)downloadSuccessOrFail:(BOOL)success;

@end

@interface CTPHAssetModel : NSObject

/**
 图片系统对象
 */
@property (nonatomic, readonly) PHAsset *asset;

/**
 图片名称
 */
@property (nonatomic, readonly) NSString *meidaName;

/**
 类型
 */
@property (nonatomic, assign) BOOL isVideo;
/**
 视频本地路径
 */
@property (nonatomic, copy) NSString *videoLocalPath;

/**
 视频对象
 */
@property (nonatomic, readonly) AVURLAsset *videoAsset;

/**
 视频播放地址
 */
@property (nonatomic, readonly) NSURL *videoUrl;
/**
 下载进度
 */
@property (nonatomic, readonly) double progress;

/**
 输出的图片 确定发送时赋值
 */
@property (nonatomic, strong) UIImage *sendImage;
//图片数据
@property (nonatomic, strong) NSData *imageData;

/**
 选择序号
 */
@property (nonatomic, copy) NSString *chooseNum;

//序号
@property (nonatomic, copy) NSIndexPath *indexPath;

/**
 是否被选中
 */
@property (nonatomic,assign) BOOL selected;

/**
 是否正在下载
 */
@property (nonatomic,assign) BOOL downloading;

@property (nonatomic, weak) id<CTPHAssetModelDelegate> delegate;

+ (instancetype)initWithAsset:(PHAsset *)asset;

/**
 同步iCloud图片或视频

 */
- (void)downLoadMediaFromiCloud;

//获取视频的URL
- (void)fetchVideoAsset:(void (^)(BOOL success))block;

/**
 获取最终数据
 @param isOrigin 是否原图
 @param block 回调
 */
- (void)creatResultData:(BOOL)isOrigin complete:(dispatch_block_t)block;

- (BOOL)checkLocalAsset;

@end
