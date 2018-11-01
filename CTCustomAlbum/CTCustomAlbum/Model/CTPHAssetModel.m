//
//  AlbumModel.m
//
//  Created by chenteng on 2017/12/4.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "CTPHAssetModel.h"
#import "CTPhotosCollectionViewCell.h"
#import "AVURLAsset+LQFetchVideo.h"
#import "UIImage+ColorImg.h"

@implementation CTPHAssetModel

+ (instancetype)initWithAsset:(PHAsset *)asset {
    return [[self alloc] initWithAsset:asset];
}
- (instancetype)initWithAsset:(PHAsset *)asset {
    self = [super init];
    if (self) {
        _asset = asset;
        _meidaName =  [asset valueForKey:@"filename"];
        _isVideo = !(asset.mediaType == PHAssetMediaTypeImage);
    }
    return self;
}
- (BOOL)checkLocalAsset {
    BOOL local = [self.asset checkLocalAsset];
    if (local&&_isVideo) {
        [self fetchVideoAsset:nil];
    }
    return local;
}
- (void)downLoadMediaFromiCloud {
    if (_downloading) {
        return;
    }
    _downloading = YES;
    WEAKSELF;
    if (!_isVideo) {
        [self.asset fetchPreviewImageComplete:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    NSLog(@"download fail %@",error);
                    weakSelf.downloading = NO;
                    if ([weakSelf.delegate respondsToSelector:@selector(downloadSuccessOrFail:)]) {
                        [weakSelf.delegate downloadSuccessOrFail:NO];
                    }
                    return;
                }
                self ->_progress = progress;
                if ([weakSelf.delegate respondsToSelector:@selector(downloadMedia:)]) {
                    [weakSelf.delegate downloadMedia:progress];
                }
                NSLog(@"图片下载进度:%f",progress);
            });
        } completeHandle:^(UIImage * _Nullable thumbImg, NSDictionary * _Nullable info) {
            //判断是否为原图
            BOOL imgDegrade = [info[PHImageResultIsDegradedKey] boolValue];
            if (!imgDegrade) {
                weakSelf.downloading = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([weakSelf.delegate respondsToSelector:@selector(downloadSuccessOrFail:)]) {
                        [weakSelf.delegate downloadSuccessOrFail:YES];
                    }
                });
            }
        }];
    }else {
        //下载视频
        [self fetchVideoAsset:nil];
    }
}

- (void)fetchVideoAsset:(void (^)(BOOL success))block {
  
    WEAKSELF;
    [self.asset fetchVideoComplete:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"download fail %@",error);
                weakSelf.downloading = NO;
                if ([weakSelf.delegate respondsToSelector:@selector(downloadSuccessOrFail:)]) {
                    [weakSelf.delegate downloadSuccessOrFail:NO];
                }
                return;
            }
            self ->_progress = progress;
            NSLog(@"视频下载进度:%f",progress);
            if ([weakSelf.delegate respondsToSelector:@selector(downloadMedia:)]) {
                [weakSelf.delegate downloadMedia:progress];
            }

        });
    } completeHandle:^(AVURLAsset *asset) {
        NSLog(@"视频下载完成:%@",asset);
     
        self -> _videoAsset = asset;
        self -> _videoUrl = asset.URL;
        weakSelf.downloading = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(downloadSuccessOrFail:)]) {
                [weakSelf.delegate downloadSuccessOrFail:YES];
            }
        });
        if (block) {
            block(YES);
        }
    }];
}
- (void)creatResultData:(BOOL)isOrigin complete:(dispatch_block_t)block {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!self.isVideo) {
            NSData *imgData = [self.asset fetchOriginImagData];
            if (imgData) {
                UIImage *img = [[UIImage imageWithData:imgData] normalizedImage];
                if (!isOrigin) {
                    imgData = UIImageJPEGRepresentation(img, CTPhotosConfiguration.outputPhotosScale);
                    img = [UIImage imageWithData:imgData];
                    NSLog(@"图片大小:%lu",(unsigned long)imgData.length);
                }
                self->_imageData = imgData;
                self->_sendImage = img;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (block) {
                    block();
                }
            });
        }else {
            //获取视频本地路径
            [self p_saveVideoToCach:isOrigin complete:^(BOOL success) {
                if (block) {
                    block();
                }
            }];
        }
    });
}

 //转换视频到本地
- (void)p_saveVideoToCach:(BOOL)isOrigin complete:(void (^)(BOOL success))block {
    [_videoAsset encodeVideo:isOrigin complete:^(bool success, NSString *fileFullPath, NSString *fileName,UIImage * shotImage) {
        self->_videoLocalPath = fileFullPath;
        self->_meidaName = fileName;
        self->_sendImage = shotImage;
        if (block) {
            block(success);
        }
    }];
}

@end
