//
//  LQTakePhotoButtomView.h
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/9/27.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import "CTBesselView.h"
#import "CTPhotosConfig.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CTTakePhotoButtomViewModel) {
    CTTakePhotoModel,            // 照片
    CTTakeVideoModel,            // 视频
    CTTakePhotoAndVideoModel     // 照片和视频
};

extern CGFloat const kTakePhotoBottomHeight;

@interface CTTakePhotoButtomView : UIView

//视频进度曲线
@property (nonatomic, strong) CTBesselView *besselView;
@property (nonatomic, assign) BOOL isCutImage;

+ (instancetype)initWithFrame:(CGRect)frame
               takePhotoModel:(CTTakePhotoButtomViewModel)takePhotoModel
                     btnBlock:(CTTouchBtnBlock)btnBlock;

- (void)completeRecord;

@end

NS_ASSUME_NONNULL_END
