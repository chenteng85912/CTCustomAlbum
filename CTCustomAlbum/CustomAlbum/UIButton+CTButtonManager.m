//
//  UIButton+CTButtonManager.m
//
//  Created by chenteng on 2017/12/14.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import "UIButton+CTButtonManager.h"
#import <objc/runtime.h>

@implementation UIButton (CTButtonManager)

- (void)blockWithControlEvents:(UIControlEvents)controlEvents
                         block:(CustomBtnBlock)btnBlcok{
    [self p_addActionBlock:btnBlcok];
    [self addTarget:self action:@selector(p_btnInvoke:) forControlEvents:controlEvents];
}

- (void)p_addActionBlock:(CustomBtnBlock)block {
    if (block) {

        objc_setAssociatedObject(self, &@selector(blockWithControlEvents:block:), block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)p_btnInvoke:(id)sender {
    CustomBtnBlock block = objc_getAssociatedObject(self, &@selector(blockWithControlEvents:block:));
    if (block) {
        block(sender);
    }
}
- (void)showAnimation{

    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(1.2,1.2);
                         
        }completion:^(BOOL finished){
         [UIView animateWithDuration:0.2 animations:^{
             self.transform = CGAffineTransformMakeScale(1.0,1.0);

         }];
                        
    }];
    
}
@end
