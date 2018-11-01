//
//  AVURLAsset+LQFetchVideo.m
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/6/23.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import "AVURLAsset+LQFetchVideo.h"
#import "CTPhotosConfig.h"

@implementation AVURLAsset (LQFetchVideo)

- (void)encodeVideo:(BOOL)isOrigin
           complete:(void (^) (bool success,NSString *fileFullPath, NSString *fileName,UIImage * shotImage))block {
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:self];

    NSString *mp4Quality = nil;
    if (isOrigin) {
        mp4Quality = AVAssetExportPreset1280x720;
    }else {
        mp4Quality = AVAssetExportPreset640x480;
    }
    if ([compatiblePresets containsObject:mp4Quality]){
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:self
                                                                               presetName:mp4Quality];
        
        NSString *fileName = [NSString stringWithFormat:@"%.3f.mp4", [[NSDate new] timeIntervalSince1970]];
        NSString *mp4Path = [CTSavePhotos.documentPath stringByAppendingPathComponent:fileName];
        
        exportSession.outputURL = [NSURL fileURLWithPath:mp4Path];
        exportSession.shouldOptimizeForNetworkUse = YES; //是否为网络传输优化
        exportSession.outputFileType = AVFileTypeMPEG4;
        //存入本地
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    //格式转换失败
                    NSLog(@"视频格式转换失败");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (block) {
                            block(NO,nil, nil,nil);
                        }
                    });
                    break;
                }
                    
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"视频格式转换取消");
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    
                    //回主线程
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"视频格式转换成功,视频路径：%@",mp4Path);
                        //block回调
                        if (block) {
                            UIImage *shotImg = [self p_getVideoShotImage:mp4Path];
                            block(YES,mp4Path, fileName,shotImg);
                        }
                    });
                    
                }
                    break;
                default:
                    break;
            }
            
        }];
    }
}
//获取视频截图
- (UIImage *)p_getVideoShotImage:(NSString *)filePath {
    
    UIImage *shotImage;
    //视频路径URL
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    shotImage = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    
    return shotImage;
    
}
@end
