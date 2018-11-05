//
//  LQCutImageController.h
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/9/28.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import "CTPhotosConfig.h"

typedef void (^CTCutImageControllerBlock)(UIImage *takeImage);

NS_ASSUME_NONNULL_BEGIN

@interface CTCutImageController : UIViewController

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) CTPHAssetModel *model;
@property (nonatomic, copy) CTCutImageControllerBlock cutBlock;//拍照后传过来的图片
@property (nonatomic, copy) CTCustomMediasBLock photoBlock;//从相册传过来的图片

@end

NS_ASSUME_NONNULL_END
