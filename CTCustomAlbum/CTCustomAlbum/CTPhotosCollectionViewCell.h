//
//  AlbumCollectionViewCell.h
//
//  Created by 腾 on 15/9/16.
//
//

#import <UIKit/UIKit.h>
#import "CTPHAssetModel.h"

@interface CTPhotosCollectionViewCell : UICollectionViewCell

/**
 选择图片按钮
 */
@property (strong, nonatomic) UIButton *selectBut;

/**
 单元格绘制

 @param assetModel 图片模型
 @param indexPath 序号
 */
- (void)processData:(CTPHAssetModel *)assetModel
          indexPath:(NSIndexPath *)indexPath;


/**
 隐藏或显示下载时候的蒙版

 @param hidden 是否隐藏
 */
- (void)showOrHiddenBackView:(BOOL)hidden;

@end
