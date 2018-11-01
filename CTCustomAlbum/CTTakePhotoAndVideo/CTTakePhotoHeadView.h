//
//  LQTakePhotoHeadView.h
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/9/27.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTPhotosConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTTakePhotoHeadView : UIView

@property (nonatomic, strong) UIButton *flashBtn;

+ (instancetype)initWithFrame:(CGRect)frame
                     btnBlock:(CTTouchBtnBlock)btnBlock;

@end

NS_ASSUME_NONNULL_END
