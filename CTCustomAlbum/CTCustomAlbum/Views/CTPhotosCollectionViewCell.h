//
//  AlbumCollectionViewCell.h
//
//  Created by 腾 on 15/9/16.
//
//

#import <UIKit/UIKit.h>
#import "CTPHAssetModel.h"

@interface CTPhotosCollectionViewCell : UICollectionViewCell<CTPHAssetModelDelegate>

@property (nonatomic, strong) UIButton *selectBut;// 选择图片按钮
@property (nonatomic, strong) UIView *backView;//蒙版
@property (nonatomic, strong) UILabel *progressLabel;//下载进度
@property (nonatomic, strong) UIImageView *frameView;//预览选中外框

/**
 单元格绘制

 @param assetModel 图片模型
 @param indexPath 序号
 @param isShow 是否显示选中框

 */
- (void)processData:(CTPHAssetModel *)assetModel
          indexPath:(NSIndexPath *)indexPath
          showFrame:(BOOL)isShow;


/**
显示下载时候的蒙版

 */
- (void)showDownloadView;

@end
