//
//  LQVideoPlayView.m
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/6/14.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import "CTVideoPlayView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "CTPHAssetModel.h"
#import "CTPlayerItem.h"

@interface CTVideoPlayView ()

@property (nonatomic, strong) AVPlayer *player;//播放器
@property (nonatomic, strong) AVPlayerLayer *playerLayer;//播放界面（layer）
@property (nonatomic, strong) CTPlayerItem *playerItem;
@property (nonatomic, strong) NSString *videoUrlStr;//视频地址
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) float totalTime;//视频总时间
@property (nonatomic, assign) BOOL playFinish;//播放完成
@property (nonatomic, assign) BOOL isPlaying;//正在播放
@property (nonatomic, assign) BOOL isLoadVideo;//加载完成

@end

@implementation CTVideoPlayView

- (void)setAssetModel:(CTPHAssetModel *)assetModel {
    _assetModel = assetModel;
    [self p_initPlayer];
}
- (void)setVideoAsset:(AVURLAsset *)videoAsset {
    _videoAsset = videoAsset;
    [self p_initPlayer];
    [self p_startPlay];

}

- (void)stopPlay {

    self.videoBtn.selected = NO;
    [self p_pausePlay];
    [_playerItem LQRemoveObserver:self  forKeyPath:@"status"];
}
#pragma mark ------------------------------------ private
//初始化播放器
- (void)p_initPlayer {
    
    _player = [[AVPlayer alloc] initWithPlayerItem:nil];
    _player.volume = 1.0; // 默认最大音量
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = self.bounds;
    [self.layer addSublayer:_playerLayer];
    if (!_videoAsset) {
        [self addSubview:self.videoBtn];
    }
    self.userInteractionEnabled = YES;
    
    //程序进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_pausePlay)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    //程序进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_continuePlay)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    //程序被挂起
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_pausePlay)
                                                 name:UIApplicationWillResignActiveNotification object:nil];

}

//开始播放视频
- (void)p_startPlayVideo {
    
    WEAKSELF;
    if (!_assetModel.videoUrl) {
        [self.indicatorView startAnimating];
        [_assetModel fetchVideoAsset:^(BOOL success){
            [weakSelf.indicatorView stopAnimating];
            if (!success) {
                [UIAlertController alertWithTitle:nil message:@"视频加载失败" cancelButtonTitle:nil otherButtonTitles:@[@"确定"] preferredStyle:UIAlertControllerStyleAlert block:nil];
                return;
            }
            weakSelf.videoBtn.selected = YES;
            [weakSelf p_initAssetModelVideoPlayer];
        }];
    }else {
        if (_isLoadVideo) {
            weakSelf.videoBtn.selected = !weakSelf.videoBtn.selected;
            if (weakSelf.videoBtn.selected) {
                [weakSelf p_continuePlay];
            }else {
                [weakSelf p_pausePlay];
            }
        }else {
            weakSelf.videoBtn.selected = YES;
            [weakSelf p_initAssetModelVideoPlayer];
        }
    }
    
}
//程序进入后台 暂停播放
- (void)p_pausePlay {
    self.playFinish = NO;
    if (_isPlaying) {
        self.videoBtn.hidden = NO;
        _isPlaying = NO;
        [self.player pause];
    }
}
//继续播放
- (void)p_continuePlay {
    if (self.playFinish) {
        [self.player seekToTime:kCMTimeZero];
    }
    [self.player play];
    self.isPlaying = YES;
}
//初始化播放信息---聊天界面 视频预览
- (void)p_initVideoPlayer{

    // 创建要播放的资源
    NSURL *url = [NSURL fileURLWithPath:_videoUrlStr];
    _playerItem = [[CTPlayerItem alloc] initWithURL:url];
    // 播放当前资源
    [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    // 添加观察者
    [self p_currentItemAddObserver];
}
//初始化播放信息---相册 视频预览
- (void)p_initAssetModelVideoPlayer{
    
    // 创建要播放的资源
    _playerItem = [[CTPlayerItem alloc] initWithURL:_assetModel.videoUrl];
    // 播放当前资源
    [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    // 添加观察者
    [self p_currentItemAddObserver];
}
//自定义拍摄视频结束后 自动播放
- (void)p_startPlay {

    // 创建要播放的资源
    _playerItem = [[CTPlayerItem alloc] initWithURL:_videoAsset.URL];
    // 播放当前资源
    [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    // 添加观察者
    [self p_currentItemAddObserver];

}
//添加观察者
- (void)p_currentItemAddObserver {
    
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [_playerItem LQAddObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:nil];
    //监控播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}

//播放完成
- (void)p_playbackFinished:(NSNotification *)notifi {
    
    //回到开头
    [self p_resetPlayInfo];
    NSLog(@"播放完成");
    if (_videoAsset) {
        [self p_startPlay];
    }
}
//重置播放信息
- (void)p_resetPlayInfo {
    self.videoBtn.hidden = NO;
    self.videoBtn.selected = NO;
    
    _playFinish = YES;
    _isPlaying = NO;
}
//进度条滑动手势
- (void)p_sliderValueChanged:(UISlider *)slider {
    [self p_pausePlay];
    
    float progressTime = slider.value * _totalTime;
    int progress = ceil(progressTime);
    [self.player seekToTime:CMTimeMake(progress, 1)];
}
#pragma mark ------------------------------------ 观察者
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        //取出status的新值
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey]intValue];
        switch (status) {
            case AVPlayerItemStatusFailed:
                NSLog(@"item 有误");
                break;
            case AVPlayerItemStatusReadyToPlay:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.isLoadVideo = YES;
                    NSLog(@"准好播放了");
                    self.totalTime = CMTimeGetSeconds(self.playerItem.duration);
                    NSLog(@"开始播放,视频总长度:%.f秒",self.totalTime);
                    [self.player play];
                    self.isPlaying = YES;
                    self.playFinish = NO;
                });
            }
                break;
            case AVPlayerItemStatusUnknown:
                NSLog(@"视频资源出现未知错误");
                break;
            default:
                break;
        }
        [_playerItem LQRemoveObserver:self  forKeyPath:@"status"];
    }
}
#pragma mark ------------------------------------ lazy
- (UIButton *)videoBtn {
    if (!_videoBtn) {
        _videoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _videoBtn.center = self.center;
        [_videoBtn setImage:kImage(@"playVideo",50,50) forState:UIControlStateNormal];
        [_videoBtn setImage:kImage(@"play_pause",50,50) forState:UIControlStateSelected];

        _videoBtn.tag = 1;
        [_videoBtn addTarget:self action:@selector(p_startPlayVideo) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoBtn;
}
- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _indicatorView.center = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
        _indicatorView.hidesWhenStopped = YES;
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [self addSubview:_indicatorView];
    }
    return _indicatorView;
}
- (void)dealloc {
    [_playerItem LQRemoveObserver:self  forKeyPath:@"status"];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end
