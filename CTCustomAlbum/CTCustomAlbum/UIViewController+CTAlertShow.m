//
//  UIViewController+CTAlertShow.m
//
//  Created by chenteng on 2017/12/17.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import "UIViewController+CTAlertShow.h"

@implementation UIViewController (CTAlertShow)

- (void)presentAlertController:(NSUInteger)maxNum
{
    NSString * title = [NSString stringWithFormat:@"你最多只能选择%@张照片",@(maxNum)];
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
    
    [self presentViewController:alertController animated:true completion:nil];
}

@end
