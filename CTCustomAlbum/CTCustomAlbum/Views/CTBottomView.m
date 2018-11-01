//
//  CTBottomView.m
//
//  Created by chenteng on 2017/12/18.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import "CTBottomView.h"
#import "CTPhotosConfig.h"

@implementation CTBottomView

- (void)drawRect:(CGRect)rect {
    [self addSubview:self.senderBtn];
    [self addSubview:self.previewBtn];
    [self addSubview:self.originBtn];
}

#pragma mark ------------------------------------ lazy
- (UIButton *)originBtn {
    if (!_originBtn) {
        _originBtn = [[UIButton alloc] initWithFrame:CGRectMake(55, 0, 60, 44)];
        [_originBtn setTitle:@"原图" forState:UIControlStateNormal];
        _originBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_originBtn setTitleColor:kColorValue(0x222222) forState:UIControlStateSelected];
        [_originBtn setTitleColor:kColorValue(0x999999) forState:UIControlStateNormal];

        _originBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        [_originBtn setImage:kImage(@"origin_unselect",20,20) forState:UIControlStateNormal];
        [_originBtn setImage:kImage(@"origin_selected",20,20) forState:UIControlStateSelected];
        [self addSubview:_originBtn];
    }
    return _originBtn;
}
- (UILabel *)imageSizeLabel {
    if (!_imageSizeLabel) {
        _imageSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.originBtn.frame)+5, 7, 60, 30)];
        _imageSizeLabel.font = [UIFont systemFontOfSize:12];
        _imageSizeLabel.textColor = [UIColor whiteColor];
    }
    return _imageSizeLabel;
}
- (UIButton *)senderBtn {
    if (!_senderBtn) {
        _senderBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-95, 7, 80, 30)];
        _senderBtn.layer.masksToBounds = YES;
        _senderBtn.layer.cornerRadius = 3.0;
        [_senderBtn setTitle:@"确定" forState:UIControlStateDisabled];
        [_senderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [_senderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _senderBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _senderBtn.backgroundColor = kColorValue(0xD8DBE4);
        _senderBtn.enabled = NO;
    }
    return _senderBtn;
}
- (UIButton *)previewBtn {
    if (!_previewBtn) {
        _previewBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 0, 40, 44)];
        _previewBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_previewBtn setTitle:@"预览" forState:UIControlStateNormal];
        [_previewBtn setTitleColor:kColorValue(0x222222) forState:UIControlStateDisabled];
        [_previewBtn setTitleColor:kColorValue(0x999999) forState:UIControlStateNormal];
        _previewBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _previewBtn.backgroundColor = UIColor.clearColor;
        _previewBtn.enabled = NO;
    }
    return _previewBtn;
}
@end
