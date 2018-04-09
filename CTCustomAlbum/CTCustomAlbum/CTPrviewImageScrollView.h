//
//  CTImageScrollView.h
//
//  Created by chenteng on 2017/11/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CTImageScrollViewDelegate <NSObject>

- (void)singalTapAction;

@end

@interface CTPrviewImageScrollView : UIScrollView

@property (nonatomic,weak) id <CTImageScrollViewDelegate> scrolDelegate;


/**
 初始化对象

 @param frame frame
 @return 返回实例化对象
 */
- (instancetype)initWithFrame:(CGRect)frame;


/**
 刷新图片

 @param img 需要显示的图片
 */
- (void)refreshShowImage:(UIImage *)img;

@end
