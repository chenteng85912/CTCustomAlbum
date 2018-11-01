//
//  CTPreviewCollectionViewCell.h
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/6/23.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTPHAssetModel.h"

@protocol CTPreviewCollectionViewCellDelegate <NSObject>

- (void)singalTapAction;

@end

@interface CTPreviewCollectionViewCell : UICollectionViewCell

@property (nonatomic,weak) id <CTPreviewCollectionViewCellDelegate> delegate;
/**
 单元格绘制
 
 @param assetModel 图片模型
 @param indexPath 序号
 */
- (void)processData:(CTPHAssetModel *)assetModel
          indexPath:(NSIndexPath *)indexPath;
//停止播放视频
- (void)stopPlay;
//隐藏播放按钮
- (void)hiddenVideoIcon;

@end
