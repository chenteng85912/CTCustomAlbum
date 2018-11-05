//
//  LQTakePhotoButtomView.m
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/9/27.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import "CTTakePhotoButtomView.h"

//视频最长时间
static float   kVideoTotalTime = 10.0;
static float   kTimerRepeat = 0.01;

CGFloat const kTakePhotoBottomHeight = 140.0;

//贝塞尔曲线宽度
static CGFloat kBesselBigWidth = 90.0;
static CGFloat kBesselNormalWidth = 70.0;
static CGFloat kInsideNormalWidth = 54.0;
static CGFloat kInsideSmallWidth = 40.0;

@interface CTTakePhotoButtomView ()
@property (nonatomic,   copy) CTTouchBtnBlock btnBlock;
@property (nonatomic, assign) CTTakePhotoButtomViewModel takePhotoModel;

//定时器
@property (nonatomic, strong) NSTimer *timer;
//内圆
@property (nonatomic, strong) UIView *insideView;
//文字提示
@property (nonatomic, strong) UILabel *tipLabel;
//贝塞尔曲线父视图
@property (nonatomic, strong) UIView *progressView;
//拍摄完成工具视图
@property (nonatomic, strong) UIView *completeView;
@end

@implementation CTTakePhotoButtomView

+ (instancetype)initWithFrame:(CGRect)frame
               takePhotoModel:(CTTakePhotoButtomViewModel)takePhotoModel
                     btnBlock:(CTTouchBtnBlock)btnBlock {
    return [[self alloc] initWithFrame:frame
                        takePhotoModel:takePhotoModel
                              btnBlock:btnBlock];
}
- (instancetype)initWithFrame:(CGRect)frame
               takePhotoModel:(CTTakePhotoButtomViewModel)takePhotoModel
                     btnBlock:(CTTouchBtnBlock)btnBlock {
    self = [super initWithFrame:frame];
    if (self) {
        _btnBlock = btnBlock;
        _takePhotoModel = takePhotoModel;
        [self p_initUI];
    }
    return self;
}
- (void)completeRecord {
    self.tipLabel.hidden = YES;
    self.completeView.hidden = NO;
    self.progressView.hidden = YES;
}
- (void)p_initUI {
    self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.2];
    self.besselView.hidden = NO;
    self.insideView.hidden = NO;
    self.tipLabel.hidden = NO;
}
- (void)p_singlePresstakePhoto {
    if (![CTSavePhotos checkAuthorityOfCamera]) {
        return;
    }
    if (self.btnBlock) {
        self.btnBlock(2);
    }
    if (!_isCutImage) {
        self.tipLabel.hidden = YES;
        self.progressView.hidden = YES;
        self.completeView.hidden = NO;
    }
}
- (void)p_longPresstakeVideo:(UILongPressGestureRecognizer *)longPress {
    if (![CTSavePhotos checkAuthorityOfCamera]||
        ![CTSavePhotos checkAuthorityofAudio]) {
        return;
    }
    if(longPress.state == UIGestureRecognizerStateBegan) {
        if (![CTSavePhotos checkAuthorityOfCamera]) {
            return;
        }
        if (![CTSavePhotos checkAuthorityofAudio]) {
            return;
        }
        self.tipLabel.hidden = YES;
        [UIView animateWithDuration:0.15 animations:^{
            CGFloat bScale = kBesselBigWidth/kBesselNormalWidth;
            CGFloat iScale = kInsideSmallWidth/kInsideNormalWidth;
            self.besselView.transform = CGAffineTransformMakeScale(bScale, bScale);
            self.insideView.transform = CGAffineTransformMakeScale(iScale, iScale);
        } completion:^(BOOL finished) {
            //开始录制
            if (self.btnBlock) {
                self.btnBlock(3);
            }
            [self.timer fire];
        }];
    }
    if (longPress.state == UIGestureRecognizerStateEnded) {
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        self.completeView.hidden = NO;
        self.progressView.hidden = YES;
        //停止录制
        if (self.btnBlock) {
            self.btnBlock(4);
        }
    }
}
#pragma mark ------------------------------------ lazy
- (NSTimer *)timer {
    if (!_timer) {
        WEAKSELF;
        _timer = [NSTimer CTScheduledTimerWithTimeInterval:kTimerRepeat repeats:YES block:^{
            CGFloat progress = weakSelf.besselView.progressValue;
            if (progress>=1.0) {
                self.completeView.hidden = NO;
                self.progressView.hidden = YES;
                if (self.btnBlock) {
                    self.btnBlock(4);
                }
            }else {
                progress = progress +kTimerRepeat/kVideoTotalTime;
                weakSelf.besselView.progressValue = progress;
            }
            
        }];
    }
    return _timer;
}
- (UILabel *)tipLabel {
    if (!_tipLabel) {
        //提示语
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12.5, kDevice_width, 15)];
        _tipLabel.textColor = UIColor.whiteColor;
        _tipLabel.font = kSystemFont(14);
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        if (_takePhotoModel==CTTakePhotoAndVideoModel) {
            _tipLabel.text = @"点击拍照，长按录像";
        }else if(_takePhotoModel == CTTakePhotoModel){
            _tipLabel.text = @"轻触拍照";
        }else {
            _tipLabel.text = @"按录像";
        }
        [self addSubview:_tipLabel];
    }
    return _tipLabel;
}
- (UIView *)completeView {
    if (!_completeView) {
        _completeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDevice_width, self.frame.size.height)];
        _completeView.backgroundColor = UIColor.clearColor;
        
        //重拍
        UIButton *resetBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, self.frame.size.height-50-30, 40, 50)];
        [resetBtn setTitle:@"重拍" forState:UIControlStateNormal];
        [resetBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        resetBtn.titleLabel.font = kSystemFont(18);
        WEAKSELF;
        [resetBtn blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender) {
            if (weakSelf.btnBlock) {
                weakSelf.btnBlock(0);
            }
            weakSelf.tipLabel.hidden = NO;
            weakSelf.completeView.hidden = YES;
            weakSelf.progressView.hidden = NO;
            weakSelf.insideView.hidden = NO;
            weakSelf.besselView.progressValue = 0;
            
            weakSelf.besselView.transform = CGAffineTransformIdentity;
            weakSelf.insideView.transform = CGAffineTransformIdentity;
        }];
        [_completeView addSubview:resetBtn];
        
        //发送
        UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(kDevice_width-15-65, self.frame.size.height-30-40, 65, 30)];
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [sendBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        sendBtn.backgroundColor = kMAINCOLOR;
        sendBtn.titleLabel.font = kSystemFont(14);
        sendBtn.layer.cornerRadius = 2.0;
        sendBtn.layer.masksToBounds = YES;
        [sendBtn blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender) {
            if (weakSelf.btnBlock) {
                weakSelf.btnBlock(1);
            }
        }];
        [_completeView addSubview:sendBtn];
        _completeView.userInteractionEnabled = YES;
        [self addSubview:_completeView];
    }
    return _completeView;
}
- (UIView *)insideView {
    if (!_insideView) {
        _insideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kInsideNormalWidth, kInsideNormalWidth)];
        _insideView.center = CGPointMake(self.progressView.frame.size.width/2, self.frame.size.height/2);
        _insideView.layer.cornerRadius = kInsideNormalWidth/2;
        _insideView.layer.masksToBounds = YES;
        _insideView.backgroundColor = UIColor.whiteColor;
        if (_takePhotoModel != CTTakeVideoModel) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_singlePresstakePhoto)];
            [_insideView addGestureRecognizer:tap];
        }
       
        if (_takePhotoModel!=CTTakePhotoModel) {
            UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(p_longPresstakeVideo:)];
            longPressGesture.minimumPressDuration = 0.5;
            [_insideView addGestureRecognizer:longPressGesture];
        }
        [self.progressView addSubview:_insideView];
    }
    return _insideView;
}
- (UIView *)progressView {
    if (!_progressView) {
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDevice_width-85*2, self.frame.size.height)];
        _progressView.center = CGPointMake(kDevice_width/2, self.frame.size.height/2);
        _progressView.backgroundColor = UIColor.clearColor;
        _progressView.userInteractionEnabled = YES;
        [self addSubview:_progressView];
    }
    return _progressView;
}

- (CTBesselView *)besselView {
    if (!_besselView) {
        _besselView = [[CTBesselView alloc] initWithFrame:CGRectMake(0, 0, kBesselNormalWidth, kBesselNormalWidth) progessColor:kMAINCOLOR progressTrackColor:UIColor.whiteColor progressStrokeWidth:5];
        _besselView.center = CGPointMake(self.progressView.frame.size.width/2, self.frame.size.height/2);
        _besselView.progressValue = 0.0;
        [self.progressView addSubview:_besselView];
    }
    return _besselView;
}
- (void)dealloc {
    if (_timer) {
        [_timer invalidate];
    }
}
@end
