//
//  AlbumCollectionViewCell.m
//
//  Created by 腾 on 15/9/16.
//
//

#import "CTPhotosCollectionViewCell.h"

@interface CTPhotosCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imgView;//缩略图
@property (nonatomic, strong) UIView *backView;//蒙版
@property (nonatomic, strong) UIActivityIndicatorView *activityView;//下载菊花

@end

@implementation CTPhotosCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)processData:(CTPHAssetModel *)assetModel
          indexPath:(NSIndexPath *)indexPath{
    
    self.imgView.image = nil;
    
    self.selectBut.selected = assetModel.selected;
    self.selectBut.tag = indexPath.row;
    
    self.backView.hidden = !assetModel.downloading;
    if (assetModel.downloading) {
        [self.activityView startAnimating];
    }else{
        [self.activityView stopAnimating];

    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    WEAKSELF;
    [assetModel.asset fetchThumbImageWithSize:CGSizeMake(width/4, width/4) complete:^(UIImage * _Nullable img,NSDictionary * _Nullable info) {

        weakSelf.imgView.image = img;

    }];
    
}

- (void)showOrHiddenBackView:(BOOL)hidden{
    self.backView.hidden = hidden;
    if (hidden) {
        [self.activityView stopAnimating];
    }else{
        [self.activityView startAnimating];

    }

}
- (UIImageView *)imgView{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = true;
        [self.contentView addSubview:_imgView];
    }
    return _imgView;
}
- (UIButton *)selectBut{
    if (!_selectBut) {
        _selectBut = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-40, self.frame.size.height-40, 40, 40)];
       
        [_selectBut setImage:[UIImage imageNamed:@"ct_unselect"] forState:UIControlStateNormal];
        [_selectBut setImage:[UIImage imageNamed:@"ct_selected"] forState:UIControlStateSelected];
        _selectBut.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 0, 0);
        [self.contentView addSubview:_selectBut];
    }
    return _selectBut;
}

- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:self.bounds];
        _backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];

        [self.contentView addSubview:_backView];
    }
    return _backView;
}
- (UIActivityIndicatorView *)activityView{
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
         _activityView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [_activityView startAnimating];
        _activityView.hidesWhenStopped = YES;
        [self.contentView addSubview:_activityView];
    }
    return _activityView;
}
@end
