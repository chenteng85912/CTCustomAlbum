//
//  CTImageScrollView.m
//
//  Created by chenteng on 2017/11/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "CTPrviewImageScrollView.h"
#import "CTPhotosConfiguration.h"

@interface CTPrviewImageScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *zoomImageView;//图片显示

@end

@implementation CTPrviewImageScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate =self;
        self.showsVerticalScrollIndicator =NO;
        self.showsHorizontalScrollIndicator =NO;
        self.maximumZoomScale = 3;
        self.minimumZoomScale = 1;

        //承载当前图片的imageview
        _zoomImageView = [[UIImageView alloc] initWithFrame:self.bounds];
   
        [self addSubview:_zoomImageView];
        
        //单击消失
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(p_singleTap:)];
        [self addGestureRecognizer:singleTapGesture];
        
        //双击放大
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(p_doubleTap:)];
        [doubleTapGesture setNumberOfTapsRequired:2];
        [self addGestureRecognizer:doubleTapGesture];
        
        [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];

    }
    return self;
}
- (void)p_singleTap:(UISwipeGestureRecognizer *)gesture {
    if ([self.scrolDelegate respondsToSelector:@selector(singalTapAction)]) {
        [self.scrolDelegate singalTapAction];
    }
}
- (void)p_doubleTap:(UITapGestureRecognizer *)gesture {
    //点击位置 为主中心 按比例选择周围区域 放到到整个屏幕
    if (self.zoomScale > 1.0) {
        [self setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [gesture locationInView:_zoomImageView];
        CGRect newRect = [self p_zoomRectForScale:self.maximumZoomScale withCenter:touchPoint];;
        [self zoomToRect:newRect animated:YES];
    }
}

//获取显示区域
- (CGRect)p_zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;

    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  /2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height /2.0);
    return zoomRect;
}

// 图片放大缩小后位置校正
#pragma mark ------------------------------------ UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGFloat offsetX = (self.bounds.size.width > self.contentSize.width)?
    (self.bounds.size.width - self.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (self.bounds.size.height > self.contentSize.height)?
    (self.bounds.size.height - self.contentSize.height) * 0.5 : 0.0;

    _zoomImageView.center = CGPointMake(self.contentSize.width * 0.5 + offsetX,
                                 self.contentSize.height * 0.5 + offsetY);
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _zoomImageView;
}
- (void)refreshShowImage:(UIImage *)img {
    if (img) {
        _zoomImageView.frame = [self p_makeImageViewFrame:img];
        _zoomImageView.image = img;
        
    }
}
//根据图片大小设置imageview的frame
- (CGRect)p_makeImageViewFrame:(UIImage *)image {
    
    CGSize imageSize = image.size;
    CGFloat scaleW = imageSize.width/Device_width;
    CGFloat picHeight = imageSize.height/scaleW;
    
    CGFloat picW;
    CGFloat picH;
    
    if (picHeight>Device_height) {
        CGFloat scaleH = picHeight/(Device_height);
        picW = Device_width/scaleH;
        picH = Device_height;
    }else{
        picW = Device_width;
        picH = picHeight;
    }
    
    CGRect newFrame = CGRectMake(Device_width/2-picW/2, Device_height/2-picH/2, picW, picH);
    return  newFrame;
}
@end
