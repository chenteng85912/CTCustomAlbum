//
//  UIControl+CTControlBlock.h
//
//  Created by chenteng on 2017/12/17.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (CTControlBlock)

- (void)controlEvents:(UIControlEvents)controlEvents
               handle:(void (^_Nullable)(__kindof UIControl * _Nonnull sender))eventHandleBlock;

@end
