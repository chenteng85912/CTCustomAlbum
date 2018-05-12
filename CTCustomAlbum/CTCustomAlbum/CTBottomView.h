//
//  CTBottomView.h
//
//  Created by chenteng on 2017/12/18.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTBottomView : UIView

/**
 发送按钮
 */
@property (nonatomic, strong) UIButton *senderBtn;

/**
 原图切换按钮
 */
@property (nonatomic, strong) UIButton *originBtn;

/**
 尺寸大小标签
 */
@property (nonatomic, strong) UILabel *imageSizeLabel;

@end
