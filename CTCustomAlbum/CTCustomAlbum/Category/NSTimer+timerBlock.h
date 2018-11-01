//
//  NSTimer+timerBlock.h
//  CommonLibraryDemo
//
//  Created by 陈腾 on 2018/4/18.
//  Copyright © 2018年 陈腾. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (timerBlock)

/**
 初始化定时器 防止循环引用 兼容 10.0以前版本，10.0之后系统可以调用自带api 

 @param interval 间隔时间
 @param repeats 是否重复
 @param block 代码块
 @return 定时器
 */

+ (NSTimer *)CTScheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      repeats:(BOOL)repeats
                                        block:(dispatch_block_t)block;

@end
