//
//  LQTakePhotoController.m
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/6/25.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import "CTTakePhotoController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+ColorImg.h"
#import "CTVideoPlayView.h"
#import "CTTakePhotoHeadView.h"
#import "CTCutImageController.h"

@interface CTTakePhotoController ()<AVCaptureFileOutputRecordingDelegate>
//设备
@property (nonatomic, strong) AVCaptureDevice * device;
//输入
@property (nonatomic, strong) AVCaptureDeviceInput * input;
//视频输出流
@property (nonatomic, strong) AVCaptureMovieFileOutput *captureMovieFileOutput;
//图片输出流
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
//流
@property (nonatomic, strong) AVCaptureSession * session;
//图层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * preview;
//视频本地路径
@property (nonatomic, strong) NSString *videoLocalPath;
//预览图片
@property (nonatomic, strong) UIImageView *previewImageView;
//焦点
@property (nonatomic, strong) UIImageView *focuseView;
//拍摄的照片
@property (nonatomic, strong) UIImage *takeImage;
//头部视图
@property (nonatomic, strong) CTTakePhotoHeadView *headView;
//底部视图
@property (nonatomic, strong) CTTakePhotoButtomView *buttomView;
//视频预览界面
@property (nonatomic, strong) CTVideoPlayView *videoPlayView;

//是否前置摄像头
@property (nonatomic,   copy) CTTakePhotoBlock takeBlock;
@property (nonatomic, assign) BOOL isFrontCamera;
@property (nonatomic, assign) BOOL isCutImage;
@property (nonatomic, assign) CTTakePhotoButtomViewModel takePhotoModel;
@property (nonatomic, assign) BOOL isLoad;

@end

@implementation CTTakePhotoController

+ (void)showTakePhotoOrVideo:(CTTakePhotoButtomViewModel)takePhotoModel
                  isCutImage:(BOOL)isCutImage
                       block:(CTTakePhotoBlock)block {
    CTTakePhotoController *take = [CTTakePhotoController new];
    take.takeBlock =  block;
    take.takePhotoModel = takePhotoModel;
    take.isCutImage = isCutImage;
    [self.p_currentViewController presentViewController:take animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    self.buttomView.hidden = NO;
}
- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];
    if (_isLoad) {
        return;
    }
    _isLoad = YES;

    [self p_setupCamera];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.windowLevel = UIWindowLevelAlert;
}
#pragma mark ------------------------------------ private
+ (UIViewController *)p_currentViewController {
    
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController *)vc).selectedViewController;
        }else if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController *)vc).visibleViewController;
        }else if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}
- (void)p_setupCamera {
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [_device lockForConfiguration:nil];
    _device.flashMode = AVCaptureFlashModeOff;
    self.headView.flashBtn.hidden = !_device.hasFlash;
    
    NSError *error=nil;
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];

    _captureMovieFileOutput = [AVCaptureMovieFileOutput new];
    //使用AVCaptureSession录制视频和音频。如果是短时间的视频录制，完全没有问题。
    //默认值就是10秒。将这个值禁用后，关闭该设置
    _captureMovieFileOutput.movieFragmentInterval = kCMTimeInvalid;
  
    // Session
    _session = [[AVCaptureSession alloc]init];
    if (kDevice_width<=375){
        _session.sessionPreset = AVCaptureSessionPreset1280x720;
    }else {
        _session.sessionPreset = AVCaptureSessionPreset1920x1080;
    }
    if ([_session canAddInput:_input]) {
        [_session addInput:_input];
    }
    //添加一个音频输入设备
    if (_takePhotoModel != CTTakePhotoModel) {
        AVCaptureDevice *audioCaptureDevice= [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput *audioCaptureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
        if (error) {
            NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
            return;
        }
        if ([_session canAddInput:_input]) {
            [_session addInput:audioCaptureDeviceInput];
        }
    }
    // Output
    if ([_session canAddOutput:_captureMovieFileOutput]) {
        [_session addOutput:_captureMovieFileOutput];
        AVCaptureConnection *captureConnection=[_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([captureConnection isVideoStabilizationSupported ]) {
            captureConnection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
        }
    }
    
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    if ([_session canAddOutput:_stillImageOutput]) {
        [_session addOutput:_stillImageOutput];
    }
    // Preview
    _preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResize;
    CGRect frame = self.view.layer.bounds;
    frame.size.height = frame.size.width*1.77;
    if (iPhoneX) {
        frame.origin.y = kDevice_height/2-frame.size.height/2;
        self.view.backgroundColor = UIColor.blackColor;
    }
    _preview.frame = frame;
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    // Start
    [_session startRunning];
    
    //聚焦
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_touchScreen:)];
    [self.view addGestureRecognizer:tap];
    //程序被挂起
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_hungUp)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
}
//开始录制视频
- (void)p_startRecord {
    
    AVCaptureConnection *captureConnection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    captureConnection.videoOrientation = self.preview.connection.videoOrientation;

    NSString *fileName = [NSString stringWithFormat:@"video_%.3f.mp4",[[NSDate new] timeIntervalSince1970]];
    _videoLocalPath = [CTSavePhotos.documentPath stringByAppendingPathComponent:fileName];
    NSURL *fileUrl = [NSURL fileURLWithPath:_videoLocalPath];
    [_captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
    self.headView.hidden = YES;
}
//拍照
- (void)p_singlePresstakePhoto {
    if (![CTSavePhotos checkAuthorityOfCamera]) {
        return;
    }
    if (_takePhotoModel != CTTakePhotoModel) {
        if (![CTSavePhotos checkAuthorityofAudio]) {
            return;
        }
    }
 
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    WEAKSELF;
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        [weakSelf.session stopRunning];
        if (imageDataSampleBuffer) {
            NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *img = [[UIImage imageWithData:jpegData] normalizedImage];
            if (weakSelf.isFrontCamera) {
                img = [img rotate:UIImageOrientationUpMirrored];
            }
            weakSelf.takeImage = img;
            
            if (weakSelf.takePhotoModel == CTTakePhotoModel&&weakSelf.isCutImage) {
                CTCutImageController *cutVc = CTCutImageController.new;
                cutVc.image = weakSelf.takeImage;
                cutVc.cutBlock = ^(UIImage *takeImage) {
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                        UIWindow *window = [UIApplication sharedApplication].keyWindow;
                        window.windowLevel = UIWindowLevelNormal;
                        if (weakSelf.takeBlock) {
                            weakSelf.takeBlock(takeImage, nil);
                        }
                    }];
                };
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cutVc];
                nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [weakSelf presentViewController:nav animated:YES completion:^{
                    [weakSelf p_resetSession];
                }];
            }else {
                weakSelf.previewImageView.hidden = NO;
                weakSelf.previewImageView.image  = img;
                weakSelf.headView.hidden = YES;
            }
        }
    }];
}

//切换摄像头
- (void)p_switchCamera {
    if (![CTSavePhotos checkAuthorityOfCamera]) {
        return;
    }
    if (_takePhotoModel != CTTakePhotoModel) {
        if (![CTSavePhotos checkAuthorityofAudio]) {
            return;
        }
    }
    _isFrontCamera = !_isFrontCamera;

    AVCaptureDevicePosition desiredPosition;
    if (!_isFrontCamera){
        desiredPosition = AVCaptureDevicePositionBack;
    }else{
        desiredPosition = AVCaptureDevicePositionFront;
    }
    if (_device.hasFlash) {
        self.headView.flashBtn.hidden = _isFrontCamera;
    }

    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([device position] == desiredPosition) {
            [_session beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
            for (AVCaptureInput *oldInput in _session.inputs) {
                [_session removeInput:oldInput];
            }
            [_session addInput:input];
            [_session commitConfiguration];
            break;
        }
    }
}
//发送照片或者视频
- (void)p_sendMedia {
    NSData *videoData = [NSData dataWithContentsOfFile:_videoLocalPath];
    if (videoData) {
        UISaveVideoAtPathToSavedPhotosAlbum(_videoLocalPath, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
    }else {
        UIImageWriteToSavedPhotosAlbum(_takeImage, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.windowLevel = UIWindowLevelNormal;
    WEAKSELF;
    [self dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.takeBlock) {
            weakSelf.takeBlock(weakSelf.takeImage,weakSelf.videoLocalPath);
        }
    }];
}
//停止录制视频
- (void)p_stopRecord {
    [_captureMovieFileOutput stopRecording];
    self.previewImageView.hidden = YES;
}
- (void)p_hungUp {
    AVAuthorizationStatus cameraStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (cameraStatus == AVAuthorizationStatusNotDetermined||
        audioStatus == AVAuthorizationStatusNotDetermined) {
        return;
    }
    if (!self.previewImageView.hidden||!self.videoPlayView.hidden) {
        return;
    }
    [self p_cancelAction];
}
//取消
- (void)p_cancelAction {

    if (_videoLocalPath) {
        [[NSFileManager defaultManager] removeItemAtPath:_videoLocalPath error:nil];
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.windowLevel = UIWindowLevelNormal;
    [_session stopRunning];
    [self dismissViewControllerAnimated:YES completion:nil];
}
//重拍
- (void)p_resetSession {
    if (_videoLocalPath) {
        [[NSFileManager defaultManager] removeItemAtPath:_videoLocalPath error:nil];
    }
    _takeImage = nil;
    _videoLocalPath = nil;
    self.previewImageView.hidden = YES;
    self.headView.hidden = NO;
    [_session startRunning];
    if (_videoPlayView) {
        [_videoPlayView stopPlay];
        _videoPlayView.hidden = YES;
    }
}
static BOOL touchScreen;
// 点击屏幕，触发聚焦
- (void)p_touchScreen:(UITapGestureRecognizer *)gesture{
    if (!self.previewImageView.hidden||!self.videoPlayView.hidden) {
        return;
    }
    if (touchScreen) {
        return;
    }
    touchScreen = YES;
    CGPoint point = [gesture locationInView:self.view];
    
    self.focuseView.center = point;
    self.focuseView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.focuseView.alpha = 1.0;
    [UIView animateWithDuration:0.15 animations:^{
        self.focuseView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.focuseView.alpha = 0;
        }];
    }];
    WEAKSELF;
    [self p_changeDevicePropertySafety:^(AVCaptureDevice *captureDevice) {
        
        // 触摸屏幕的坐标点需要转换成0-1，设置聚焦点
        CGPoint cameraPoint = [self.preview captureDevicePointOfInterestForPoint:point];
        
        /*****必须先设定聚焦位置，在设定聚焦方式******/
        //聚焦点的位置
        if ([weakSelf.device isFocusPointOfInterestSupported]) {
            [weakSelf.device setFocusPointOfInterest:cameraPoint];
        }
        
        // 聚焦模式
        if ([weakSelf.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [weakSelf.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }else{
            NSLog(@"聚焦模式修改失败");
        }
        
        //曝光点的位置
        if ([weakSelf.device isExposurePointOfInterestSupported]) {
            [weakSelf.device setExposurePointOfInterest:cameraPoint];
        }
        
        //曝光模式
        if ([weakSelf.device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            [weakSelf.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }else{
            NSLog(@"曝光模式修改失败");
        }
        // 防止点击一次，多次聚焦，会连续拍多张照片
        touchScreen = NO;
    }];
}

- (void)p_changeDevicePropertySafety:(void (^)(AVCaptureDevice *device))propertyChange{
    //也可以直接用_videoDevice,但是下面这种更好
    AVCaptureDevice *captureDevice= _input.device;
    //AVCaptureDevice *captureDevice= self.device;
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁,意义是---进行修改期间,先锁定,防止多处同时修改
    BOOL lockAcquired = [captureDevice lockForConfiguration:&error];
    if (!lockAcquired) {
        NSLog(@"锁定设备过程error，错误信息：%@",error.localizedDescription);
    }else{
        [_session beginConfiguration];
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
        [_session commitConfiguration];
    }
}

#pragma mark ------------------------------------ AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    NSLog(@"开始录制...");
}
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    [_session stopRunning];

    _takeImage = [UIImage getVideoShotImage:outputFileURL];
    
    [self.buttomView completeRecord];
    self.previewImageView.hidden = YES;
    NSLog(@"录制完成...");
    self.videoPlayView.hidden = NO;
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:outputFileURL options:nil];
    self.videoPlayView.videoAsset = asset;
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    }else {
        
    }
}
- (void)savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    if (error) {
        NSLog(@"保存视频失败%@", error.localizedDescription);
    }else {
        NSLog(@"保存视频成功");
    }
}
#pragma mark ------------------------------------ lazy
- (CTTakePhotoButtomView *)buttomView {
    if (!_buttomView) {
        WEAKSELF;
        _buttomView = [CTTakePhotoButtomView  initWithFrame:CGRectMake(0, kDevice_height-kTakePhotoBottomHeight, kDevice_width, kTakePhotoBottomHeight) takePhotoModel:_takePhotoModel btnBlock:^(NSInteger index) {
            if (index==0) {
                [weakSelf p_resetSession];
            }else if (index==1) {
                [weakSelf p_sendMedia];
            }else if (index==2) {
                [weakSelf p_singlePresstakePhoto];
            }else if (index==3) {
                [weakSelf p_startRecord];
            }else {
                [weakSelf p_stopRecord];
            }
        }];
        _buttomView.isCutImage = _isCutImage;
        [self.view addSubview:_buttomView];
    }
    return _buttomView;
}

- (UIImageView *)previewImageView {
    if (!_previewImageView) {
        _previewImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        CGRect frame = self.view.layer.bounds;
        frame.size.height = frame.size.width*1.77;
        if (iPhoneX) {
            frame.origin.y = kDevice_height/2-frame.size.height/2;
        }
        _previewImageView.frame = frame;
        _previewImageView.hidden = YES;
        [self.view addSubview:_previewImageView];
    }
    [self.view bringSubviewToFront:self.buttomView];
    return _previewImageView;
}
- (CTVideoPlayView *)videoPlayView {
    if (!_videoPlayView) {
        _videoPlayView = [[CTVideoPlayView alloc] initWithFrame:self.view.bounds];
        _videoPlayView.hidden = YES;
        [self.view addSubview:_videoPlayView];
    }
    [self.view bringSubviewToFront:self.buttomView];
    return _videoPlayView;
}

- (CTTakePhotoHeadView *)headView {
    if (!_headView) {
        WEAKSELF;
        _headView = [CTTakePhotoHeadView initWithFrame:CGRectMake(0, 0, kDevice_width, 100) btnBlock:^(NSInteger index) {
            if (index==0) {
                [weakSelf p_cancelAction];
            }else if (index==1){
                [weakSelf p_switchCamera];
            }else if (index==2){
                [weakSelf.device lockForConfiguration:nil];
                weakSelf.device.flashMode = AVCaptureFlashModeOff;
            }else {
                [weakSelf.device lockForConfiguration:nil];
                weakSelf.device.flashMode = AVCaptureFlashModeOn;
            }
        }];
        [self.view addSubview:_headView];
    }
    return _headView;
}

- (UIImageView *)focuseView {
    if (!_focuseView) {
        _focuseView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _focuseView.image = kImage(@"对焦框",80,80);
        [self.view addSubview:_focuseView];
        _focuseView.alpha = 0.0;
    }
    return _focuseView;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}
@end
