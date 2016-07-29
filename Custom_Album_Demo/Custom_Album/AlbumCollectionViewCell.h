//
//  AlbumCollectionViewCell.h
//  eyerecolor
//
//  Created by 腾 on 15/9/16.
//
//

#import <UIKit/UIKit.h>

@interface AlbumCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *selectBut;//选择按钮
@property (weak, nonatomic) IBOutlet UIImageView *cameraView;//拍照图标
@property (weak, nonatomic) IBOutlet UIView *backView;//选中阴影背景

@property (strong, nonatomic) IBOutlet UIImageView *imgView;//缩略图
@end
