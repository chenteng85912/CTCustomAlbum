//
//  UIButton+CTButtonManager.h
//
//  Created by chenteng on 2017/12/14.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CustomBtnBlock)(UIButton *sender);

@interface UIButton (CTButtonManager)

- (void)blockWithControlEvents:(UIControlEvents)controlEvents
                         block:(CustomBtnBlock)btnBlcok;

- (void)showAnimation;

@end
