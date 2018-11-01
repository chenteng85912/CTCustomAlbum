//
//  CTImageScrollView.h
//
//  Created by chenteng on 2017/11/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

//大图预览cell里面承载图片预览的视图  图片裁剪承载图片预览的视图
@protocol CTPrviewImageScrollViewDelegate <NSObject>

@optional
- (void)singalTapAction;

@end

@interface CTPreviewScrollView : UIScrollView
@property (nonatomic,weak) id <CTPrviewImageScrollViewDelegate> scrDelegate;

/**
 初始化对象

 @param frame frame
 @param isDoubleTap isDoubleTap
 @return 返回实例化对象
 */
- (instancetype)initWithFrame:(CGRect)frame doubleTap:(BOOL)isDoubleTap;

/**
 刷新图片

 @param img 需要显示的图片
 */
- (void)refreshShowImage:(UIImage *)img;

//图片裁剪 位置重置
- (void)cutImageAutoAdjustFrame:(UIImage *)image;

//获取裁剪框位置
- (CGRect)getCutFrame;

@end
