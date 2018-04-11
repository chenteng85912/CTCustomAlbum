//
//  UIButton+CTButtonManager.h
//
//  Created by chenteng on 2017/12/14.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CustomBtnBlock)(UIButton *sender);

@interface UIButton (CTButtonManager)

/**
 按钮点击动作

 @param controlEvents 按钮点击事件
 @param btnBlcok 按钮点击回调
 */
- (void)blockWithControlEvents:(UIControlEvents)controlEvents
                         block:(CustomBtnBlock)btnBlcok;


/**
 按钮点击动画
 */
- (void)showAnimation;

@end
