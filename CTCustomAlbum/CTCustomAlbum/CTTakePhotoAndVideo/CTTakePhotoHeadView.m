//
//  LQTakePhotoHeadView.m
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/9/27.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import "CTTakePhotoHeadView.h"

@interface CTTakePhotoHeadView ()
@property (nonatomic, copy) CTTouchBtnBlock btnBlock;

@end

@implementation CTTakePhotoHeadView

+ (instancetype)initWithFrame:(CGRect)frame
                     btnBlock:(CTTouchBtnBlock)btnBlock {
    return [[self alloc] initWithFrame:frame btnBlock:btnBlock];
}
- (instancetype)initWithFrame:(CGRect)frame
                     btnBlock:(CTTouchBtnBlock)btnBlock {
    self = [super initWithFrame:frame];
    if (self) {
        _btnBlock = btnBlock;
        [self p_initUI];
    }
    return self;
}

- (void)p_initUI {
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, iPhoneX?30:15, 40, 40)];
    [closeBtn setImage:kImage(@"close",20,20) forState:UIControlStateNormal];
    [self addSubview:closeBtn];
    
    UIButton *flashBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-100, iPhoneX?30:15, 40, 40)];
    [flashBtn setImage:kImage(@"闪光灯关闭",20,20) forState:UIControlStateNormal];
    [flashBtn setImage:kImage(@"闪光灯开启",20,20) forState:UIControlStateSelected];
    _flashBtn = flashBtn;
    [self addSubview:flashBtn];
    
    UIButton *switchBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-45, iPhoneX?30:15, 40, 40)];
    [switchBtn setImage:kImage(@"摄像头转换",20,20) forState:UIControlStateNormal];
    [self addSubview:switchBtn];
    
    WEAKSELF;
    [closeBtn blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender) {
        if (weakSelf.btnBlock) {
            weakSelf.btnBlock(0);
        }
    }];
    [flashBtn blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender) {
        sender.selected = !sender.selected;
        if (weakSelf.btnBlock) {
            if (sender.selected) {
                weakSelf.btnBlock(3);
            }else {
                weakSelf.btnBlock(2);
            }
        }
    }];
    [switchBtn blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender) {
        if (weakSelf.btnBlock) {
            weakSelf.btnBlock(1);
        }
    }];
}
@end
