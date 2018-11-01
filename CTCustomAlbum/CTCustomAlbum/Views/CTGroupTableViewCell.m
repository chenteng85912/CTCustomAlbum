//
//  CTGroupTableViewCell.m
//
//  Created by chenteng on 2017/12/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "CTGroupTableViewCell.h"
#import "CTGroupModel.h"

CGFloat const sub_x = 15;
CGFloat const sub_y = 12;

@interface CTGroupTableViewCell ()

@property (nonatomic, strong) UIImageView *thumbImgView;
@property (nonatomic, strong) UIImageView *videoIcon;
@property (nonatomic, strong) UILabel *groupTitleLabel;
@property (nonatomic, strong) UILabel *numberTitleLabel;

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

- (void)processCellData:(CTGroupModel *)colModel {
    self.groupTitleLabel.text = nil;
    self.thumbImgView.image = nil;
    self.numberTitleLabel.text = nil;
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.thumbImgView.image = colModel.iconImg;
    self.groupTitleLabel.text = colModel.groupName;
    self.numberTitleLabel.text = [NSString stringWithFormat:@"%ld",(long)colModel.totalNum];
    
    self.videoIcon.hidden = !colModel.isVideo;
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
//视频图标
- (UIImageView *)videoIcon {
    if (!_videoIcon) {
        _videoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _videoIcon.center = self.thumbImgView.center;
        _videoIcon.image = kImage(@"playVideo",10,10);
        [self.contentView addSubview:_videoIcon];
    }
    return _videoIcon;
}
//标题
- (UILabel *)groupTitleLabel{
    if (!_groupTitleLabel) {
        _groupTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.thumbImgView.frame)+sub_x, 22, [UIScreen mainScreen].bounds.size.width-CGRectGetMaxX(self.thumbImgView.frame)-sub_x*2, 22)];
        _groupTitleLabel.font = kSystemFont(17);
        [self.contentView addSubview:_groupTitleLabel];
    }
    return _groupTitleLabel;
}
- (UILabel *)numberTitleLabel{
    if (!_numberTitleLabel) {
        _numberTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.thumbImgView.frame)+sub_x, 53, [UIScreen mainScreen].bounds.size.width-CGRectGetMaxX(self.thumbImgView.frame)-sub_x*2, 22)];
        _numberTitleLabel.font = kSystemFont(14);
        _numberTitleLabel.textColor = kColorValue(0x222222);
        [self.contentView addSubview:_numberTitleLabel];
    }
    return _numberTitleLabel;
}
@end
