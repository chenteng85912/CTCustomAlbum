//
//  LQVideoPlayView.h
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/6/14.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class CTPHAssetModel;
@interface CTVideoPlayView : UIView

/**
 相册预览视频时 传入的模型
 */
@property (nonatomic, strong) CTPHAssetModel *assetModel;

/**
 手动拍摄视频时 传入的对象
 */
@property (nonatomic, strong) AVURLAsset *videoAsset;

@property (nonatomic, strong) UIButton *videoBtn;//播放按钮

//停止播放
- (void)stopPlay;

@end
