//
//  UIControl+CTControlBlock.m
//
//  Created by chenteng on 2017/12/17.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import "UIControl+CTControlBlock.h"
#import <objc/runtime.h>

@implementation UIControl (CTControlBlock)

- (void)controlEvents:(UIControlEvents)controlEvents
               handle:(void (^)(__kindof UIControl * _Nonnull sender))eventHandleBlock{
    if (!eventHandleBlock)
    {
        return;
    }
    //将block缓存
    objc_setAssociatedObject(self, &@selector(controlEvents:handle:), eventHandleBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    //添加目标动作回调
    [self addTarget:self action:@selector(actionFunction) forControlEvents:controlEvents];
}

- (void)actionFunction{
    //获得block
    void(^block)(UIControl *)  = (void(^)(UIControl *))objc_getAssociatedObject(self, &@selector(controlEvents:handle:));
    
    if (block) {
        
        block(self);//执行方法
    }

}
@end
