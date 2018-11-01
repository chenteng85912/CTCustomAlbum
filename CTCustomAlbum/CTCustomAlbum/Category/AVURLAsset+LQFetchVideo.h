//
//  AVURLAsset+LQFetchVideo.h
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/6/23.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVURLAsset (LQFetchVideo)

- (void)encodeVideo:(BOOL)isOrigin
           complete:(void (^) (bool success,NSString *fileFullPath, NSString *fileName,UIImage * shotImage))block;

@end
