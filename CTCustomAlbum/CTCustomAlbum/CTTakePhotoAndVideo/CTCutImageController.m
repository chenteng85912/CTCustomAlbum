//
//  LQCutImageController.m
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/9/28.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import "CTCutImageController.h"
#import "CTPreviewScrollView.h"

@interface CTCutImageController ()

@property (nonatomic, strong) CTPreviewScrollView *imgView;//图片预览
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIView *centerView;//切图框
@property (nonatomic, strong) UIView *bottomView;

@end

@implementation CTCutImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.imgView cutImageAutoAdjustFrame:_image];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if (_model) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        window.windowLevel = UIWindowLevelAlert;
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (UIImage *)p_scaleImage:(UIImage *)image toSize:(CGSize)size {
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [image drawInRect:rect];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}
//切图
- (UIImage *)p_cutImage:(UIImage *)img cutFrame:(CGRect)rect {
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(img.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    return smallImage;
    
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    }
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kDevice_height-(kDevice_height-kDevice_width)/2, kDevice_width, (kDevice_height-kDevice_width)/2)];
        _bottomView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.4];
        
        //取消
        UIButton *resetBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, _bottomView.frame.size.height-50-30, 40, 50)];
        [resetBtn setTitle:@"取消" forState:UIControlStateNormal];
        [resetBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        resetBtn.titleLabel.font = kSystemFont(18);
        WEAKSELF;
        [resetBtn blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender) {
            if (weakSelf.presentingViewController && weakSelf.navigationController.viewControllers.count == 1) {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            } else {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            if (weakSelf.model) {
                UIWindow *window = [UIApplication sharedApplication].keyWindow;
                window.windowLevel = UIWindowLevelNormal;
            }
        }];
        [_bottomView addSubview:resetBtn];
        
        //发送
        UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(kDevice_width-15-65, _bottomView.frame.size.height-30-40, 65, 30)];
        [sendBtn setTitle:@"确定" forState:UIControlStateNormal];
        [sendBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        sendBtn.backgroundColor = kMAINCOLOR;
        sendBtn.titleLabel.font = kSystemFont(14);
        sendBtn.layer.cornerRadius = 2.0;
        sendBtn.layer.masksToBounds = YES;
        [sendBtn blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            if (weakSelf.model) {
                UIWindow *window = [UIApplication sharedApplication].keyWindow;
                window.windowLevel = UIWindowLevelNormal;
            }
            UIImage *resultImg = [weakSelf p_cutImage:weakSelf.image cutFrame:[weakSelf.imgView getCutFrame]];
            if (!resultImg) {
                return;
            }
            CGFloat kMaxHeadWidth;
            if (kDevice_width>375) {
                kMaxHeadWidth = 800;
            }else {
                kMaxHeadWidth = 700;
            }
            CGFloat scale = CTPhotosConfiguration.outputPhotosScale;
            if (resultImg.size.width>kMaxHeadWidth) {
                CGFloat imgScale = kMaxHeadWidth/resultImg.size.width;
                scale = imgScale<scale?imgScale:scale;
                resultImg = [self p_scaleImage:resultImg toSize:CGSizeMake(kMaxHeadWidth, kMaxHeadWidth)];
            }
            UIImageWriteToSavedPhotosAlbum(resultImg, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)weakSelf);
            if (weakSelf.cutBlock) {
                weakSelf.cutBlock(resultImg);
            }
            if (weakSelf.photoBlock) {
                weakSelf.model.sendImage = resultImg;
                weakSelf.model.imageData = UIImageJPEGRepresentation(resultImg, scale);
                weakSelf.photoBlock(@[weakSelf.model]);
            }
        }];
        [_bottomView addSubview:sendBtn];
        _bottomView.userInteractionEnabled = YES;
    }
    return _bottomView;
}

- (UIView *)headView {
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDevice_width, (kDevice_height-kDevice_width)/2)];
        _headView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.4];
    }
    return _headView;
}
- (UIView *)centerView {
    if (!_centerView) {
        _centerView = [[UIView alloc] initWithFrame:CGRectMake(0, (kDevice_height-kDevice_width)/2, kDevice_width, kDevice_width)];
        _centerView.backgroundColor = UIColor.clearColor;
        _centerView.layer.borderColor = UIColor.whiteColor.CGColor;
        _centerView.layer.borderWidth = 1;
    }
    return _centerView;
}
- (CTPreviewScrollView *)imgView {
    if (!_imgView) {
        _imgView = [[CTPreviewScrollView alloc] initWithFrame:self.view.bounds doubleTap:NO];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = true;
        _imgView.backgroundColor = UIColor.blackColor;
        _imgView.maximumZoomScale = 3;
        if (@available(iOS 11.0, *)) {
            _imgView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        UIView *backView = [[UIView alloc] initWithFrame:self.view.bounds];
        [backView addSubview:self.bottomView];
        [backView addSubview:self.headView];
        [backView addSubview:self.centerView];
        backView.tag = 1001;
        [_imgView addSubview:backView];
        [self.view addSubview:_imgView];
    }
    return _imgView;
}
- (void)dealloc {
    NSLog(@"dealloc:%@",self);
}
@end
