//
//  TJCircleView.h
//  LHCircleView
//
//  Created by Apple on 16/8/18.
//  Copyright © 2016年 liuhuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTBesselView : UIView

@property (nonatomic,assign) CGFloat progressValue;// 贝塞尔曲线进度

/*
 *初始化贝塞尔曲线 frame 颜色 进度条滚动颜色 进度条背景颜色
 */
- (instancetype)initWithFrame:(CGRect)frame progessColor:(UIColor *)pColor progressTrackColor:(UIColor *)tColor progressStrokeWidth:(CGFloat)sWidth;

@end
