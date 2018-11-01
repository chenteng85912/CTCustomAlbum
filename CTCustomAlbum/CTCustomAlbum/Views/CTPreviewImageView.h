//
//  CTPreviewImageView.h
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/9/25.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import <UIKit/UIKit.h>

//大图预览界面 底部小图预览视图 里面嵌套了一个流水布局
NS_ASSUME_NONNULL_BEGIN

@class CTPHAssetModel;
typedef void (^CTPreviewImageViewBlock)(CTPHAssetModel *model);

extern CGFloat const kPreviewImageHeight;

@interface CTPreviewImageView : UIView

@property (nonatomic, copy) CTPreviewImageViewBlock didCellBlock;

+ (instancetype)initWithFrame:(CGRect)frame
                   dataSource:(NSMutableArray *)dataArrm;

- (void)refreshData:(CTPHAssetModel *)curruntModel;

@end

NS_ASSUME_NONNULL_END
