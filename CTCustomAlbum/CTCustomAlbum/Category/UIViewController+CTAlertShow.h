//
//  UIViewController+CTAlertShow.h
//
//  Created by chenteng on 2017/12/17.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CTAlertShow)

/**
 最大选择数量警告

 @param maxNum 最大选择数量 默认为9
 */
- (void)presentAlertController:(NSUInteger)maxNum;

@end
