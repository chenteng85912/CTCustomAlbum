//
//  CTGroupTableViewCell.m
//
//  Created by chenteng on 2017/12/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "CTGroupTableViewCell.h"
#import "PHAssetCollection+CTAssetCollectionManager.h"

CGFloat const sub_x = 10;
CGFloat const sub_y = 5;

@interface CTGroupTableViewCell ()

@property (nonatomic, strong) UIImageView *thumbImgView;
@property (nonatomic, strong) UILabel *groupTitleLabel;

@end

@implementation CTGroupTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)processCellData:(PHAssetCollection *)collection {
    self.groupTitleLabel.text = nil;
    self.thumbImgView.image = nil;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [collection fetchCollectionInfoWithSize:CGSizeMake(60, 60) complete:^(NSString * _Nonnull title, NSUInteger assetCount, UIImage * _Nullable image) {
        self.thumbImgView.image = image;

        NSString *count = [NSString stringWithFormat:@"(%lu)",(unsigned long)assetCount];
        NSMutableAttributedString *countStr = [[NSMutableAttributedString alloc] initWithString:count attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];

        NSMutableAttributedString *titleAtt = [[NSMutableAttributedString alloc] initWithString:title];
        [titleAtt appendAttributedString:countStr];
        [titleAtt addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} range:NSMakeRange(0, titleAtt.length)];
        self.groupTitleLabel.attributedText = titleAtt;
    }];
}
#pragma mark ------------------------------------ lazy
//缩略图
- (UIImageView *)thumbImgView {
    if (!_thumbImgView) {
        _thumbImgView = [[UIImageView alloc] initWithFrame:CGRectMake(sub_x, sub_y, self.frame.size.height-sub_y*2, self.frame.size.height-sub_y*2)];
        _thumbImgView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImgView.clipsToBounds = true;
        [self.contentView addSubview:_thumbImgView];
    }
    return _thumbImgView;
}
//标题
- (UILabel *)groupTitleLabel{
    if (!_groupTitleLabel) {
        _groupTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.thumbImgView.frame)+sub_x, 0, [UIScreen mainScreen].bounds.size.width-CGRectGetMaxX(self.thumbImgView.frame)-sub_x*2, self.frame.size.height)];
        _groupTitleLabel.numberOfLines = 0;
        [self.contentView addSubview:_groupTitleLabel];
        
    }
    return _groupTitleLabel;
}
@end
