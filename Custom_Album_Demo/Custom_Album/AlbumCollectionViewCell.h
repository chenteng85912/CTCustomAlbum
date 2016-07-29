//
//  AlbumCollectionViewCell.h
//  eyerecolor
//
//  Created by 腾 on 15/9/16.
//
//

#import <UIKit/UIKit.h>

@interface AlbumCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *selectBut;
@property (weak, nonatomic) IBOutlet UIImageView *cameraView;
@property (weak, nonatomic) IBOutlet UIView *backView;

@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@end
