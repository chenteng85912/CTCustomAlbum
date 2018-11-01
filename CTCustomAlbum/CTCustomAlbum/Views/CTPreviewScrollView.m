//
//  CTImageScrollView.m
//
//  Created by chenteng on 2017/11/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "CTPreviewScrollView.h"
#import "CTPhotosConfig.h"

NSString *const kPreviewScrViewContentOffsetKey = @"self.contentOffset";

@interface CTPreviewScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *zoomImageView;//图片显示
@property (nonatomic, assign) CGFloat insetY;
@property (nonatomic, assign) CGFloat insetX;
@property (nonatomic, assign) CGFloat contentSubY;
@property (nonatomic, assign) CGFloat contentSubX;

@end

@implementation CTPreviewScrollView

- (instancetype)initWithFrame:(CGRect)frame doubleTap:(BOOL)isDoubleTap{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate =self;
        self.showsVerticalScrollIndicator =NO;
        self.showsHorizontalScrollIndicator =NO;
        self.minimumZoomScale = 1;
        //承载当前图片的imageview
        _zoomImageView = [[UIImageView alloc] initWithFrame:self.bounds];
   
        [self addSubview:_zoomImageView];
        
        //单击消失
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(p_singleTap:)];
        [self addGestureRecognizer:singleTapGesture];
        if (isDoubleTap) {
            self.maximumZoomScale = 3;
            //双击放大
            UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(p_doubleTap:)];
            [doubleTapGesture setNumberOfTapsRequired:2];
            [self addGestureRecognizer:doubleTapGesture];
            [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
        }
        [self addObserver:self forKeyPath:kPreviewScrViewContentOffsetKey options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];

        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)p_singleTap:(UITapGestureRecognizer *)gesture {
    if ([self.scrDelegate respondsToSelector:@selector(singalTapAction)]) {
        [self.scrDelegate singalTapAction];
    }
}
- (void)p_doubleTap:(UITapGestureRecognizer *)gesture {
    //点击位置 为主中心 按比例选择周围区域 放到到整个屏幕
    if (self.zoomScale > 1.0) {
        [self setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [gesture locationInView:_zoomImageView];
        CGRect newRect = [self p_zoomRectForScale:2 withCenter:touchPoint];;
        [self zoomToRect:newRect animated:YES];
    }
    self.frame = CGRectMake(-5, 0, self.frame.size.width, self.frame.size.height);
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
    _zoomImageView.center = CGPointMake(self.contentSize.width * 0.5 + offsetX, self.contentSize.height * 0.5 + offsetY);

}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _zoomImageView;
}

- (void)refreshShowImage:(UIImage *)img {
    self.zoomScale = 1.0;
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

    if (img) {
        _zoomImageView.frame = [self p_makeImageViewFrame:img];
    }
    _zoomImageView.image = img;
}

- (CGRect)getCutFrame {
    UIImage *img = _zoomImageView.image;
    CGFloat scaleW = img.size.width/kDevice_width;
    CGFloat picHeight = img.size.height/scaleW;
    
    if (picHeight<kDevice_width) {
        scaleW = img.size.height/kDevice_width;
    }
    
    CGRect frame = CGRectZero;
    frame.origin.y = (self.contentInset.top+self.contentOffset.y)*scaleW/self.zoomScale;
    frame.origin.x = (self.contentInset.left+self.contentOffset.x)*scaleW/self.zoomScale;
    frame.size.width = ceilf(kDevice_width*scaleW/self.zoomScale);
    frame.size.height = ceilf(kDevice_width*scaleW/self.zoomScale);

    NSLog(@"切图位置大小:%@",NSStringFromCGRect(frame));
    return frame;
}
//设置切图位置
- (void)cutImageAutoAdjustFrame:(UIImage *)image {
    self.zoomScale = 1.0;
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGSize imageSize = image.size;
    //宽度比例
    CGFloat scaleW = imageSize.width/kDevice_width;
    CGFloat picHeight = imageSize.height/scaleW;
    NSInteger zoomSub = self.maximumZoomScale-self.minimumZoomScale;

    CGFloat picW = 0;
    CGFloat picH = 0;
    CGFloat insetY = 0;
    CGFloat insetX = 0;
    if (picHeight<kDevice_width) {
        CGFloat scaleH = kDevice_width/picHeight;
        picH = kDevice_width;
        picW = kDevice_width*scaleH;
        insetX = (picW-kDevice_width)/2;
        if (zoomSub>0) {
            _contentSubX = ceilf((picW-kDevice_width)/zoomSub);
        }
    }else {
        picW = kDevice_width;
        picH = picHeight;
        insetY = (picHeight-kDevice_width)/2;
    }

    CGRect newFrame = CGRectMake(kDevice_width/2-picW/2, kDevice_height/2-picH/2, picW, picH);
    _zoomImageView.frame = newFrame;
    _zoomImageView.image = image;

    if (zoomSub>0) {
        _contentSubY = ceilf((picHeight-kDevice_height)/zoomSub);
    }
    _insetX = insetX;
    _insetY = insetY;
    self.contentInset = UIEdgeInsetsMake(insetY, insetX, insetY, insetX);
}
//根据图片大小设置imageview的frame
- (CGRect)p_makeImageViewFrame:(UIImage *)image {
    if (!image) {
        return CGRectZero;
    }
    CGSize imageSize = image.size;
    CGFloat scaleW = imageSize.width/kDevice_width;
    CGFloat picHeight = imageSize.height/scaleW;
    
    CGFloat picW;
    CGFloat picH;
    if (picHeight>kDevice_height) {
        CGFloat scaleH = picHeight/(kDevice_height);
        picW = kDevice_width/scaleH;
        picH = kDevice_height;
    }else{
        picW = kDevice_width;
        picH = picHeight;
    }
    
    CGRect newFrame = CGRectMake(kDevice_width/2-picW/2, kDevice_height/2-picH/2, picW, picH);
    return  newFrame;
}
#pragma mark ------------------------------------ kvo
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if (object == self && [keyPath isEqualToString:kPreviewScrViewContentOffsetKey]) {
        CGPoint newOffset = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        UIView *backView = [self viewWithTag:1001];
        if (backView) {
            CGRect frame = backView.frame;
            frame.origin.x = newOffset.x;
            frame.origin.y = newOffset.y;
            backView.frame = frame;
        }
//        NSLog(@"zoom:%f inset:%@ offset:%@",self.zoomScale,NSStringFromUIEdgeInsets(self.contentInset),NSStringFromCGPoint(newOffset));
        self.contentSize = CGSizeMake(kDevice_width*self.zoomScale, kDevice_height*self.zoomScale);
        CGFloat insetY = ceilf(_insetY+(self.zoomScale-1)*_contentSubY);
        CGFloat insetX = ceilf(_insetX+(self.zoomScale-1)*_contentSubX);
        self.contentInset = UIEdgeInsetsMake(insetY, insetX, insetY, insetX);
    }
}
- (void)dealloc {
    [self removeObserver:self forKeyPath:kPreviewScrViewContentOffsetKey];
}
@end
