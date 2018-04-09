//
//  AlbumCollectionViewCell.h
//
//  Created by 腾 on 15/9/16.
//
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "CTPHAssetModel.h"

typedef void (^PhotosBtnBlock)(NSIndexPath *indexPath);

@interface CTPhotosCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIButton *selectBut;


- (void)processData:(CTPHAssetModel *)assetModel
          indexPath:(NSIndexPath *)indexPath;

- (void)showOrHiddenBackView:(BOOL)hidden;

@end
