//
//  CTPreviewCollectionViewCell.m
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/6/23.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import "CTPreviewCollectionViewCell.h"
#import "CTVideoPlayView.h"
#import "CTPreviewScrollView.h"

@interface CTPreviewCollectionViewCell ()<CTPrviewImageScrollViewDelegate>

@property (nonatomic, strong) CTPreviewScrollView *imgView;//缩略图
@property (nonatomic, strong) CTVideoPlayView *videoPlayView;
@property (nonatomic, strong) CTPHAssetModel *assetModel;

@end

@implementation CTPreviewCollectionViewCell

- (void)processData:(CTPHAssetModel *)assetModel
          indexPath:(NSIndexPath *)indexPath {
    self.backgroundColor = UIColor.blackColor;
    _assetModel = assetModel;
    [self.imgView refreshShowImage:nil];
    if (_videoPlayView) {
        [_videoPlayView stopPlay];
        [_videoPlayView removeFromSuperview];
        _videoPlayView = nil;
    }
    WEAKSELF;
    [assetModel.asset fetchPreviewImageComplete:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        
    } completeHandle:^(UIImage * _Nullable thumbImg, NSDictionary * _Nullable info) {
        [weakSelf.imgView refreshShowImage:thumbImg];
        self.videoPlayView.hidden = !assetModel.isVideo;
        if (assetModel.isVideo) {
            self.videoPlayView.assetModel = assetModel;
        }
    }];
}
- (void)stopPlay {
    if (_videoPlayView) {
        [_videoPlayView stopPlay];
    }
}
#pragma mark ------------------------------------ CTPrviewImageScrollViewDelegate
- (void)singalTapAction {
    if ([self.delegate respondsToSelector:@selector(singalTapAction)]) {
        [self.delegate singalTapAction];
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window.windowLevel == UIWindowLevelAlert) {
        //隐藏
        self.videoPlayView.videoBtn.hidden = YES;
    }else {
        self.videoPlayView.videoBtn.hidden = NO;
    }
}
- (void)hiddenVideoIcon {
    
    if (_videoPlayView) {
        _videoPlayView.videoBtn.hidden = YES;
    }
}
- (CTPreviewScrollView *)imgView {
    if (!_imgView) {
        
        _imgView = [[CTPreviewScrollView alloc] initWithFrame:self.bounds doubleTap:!self.assetModel.isVideo];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = true;
        _imgView.scrDelegate = self;
        [self.contentView addSubview:_imgView];
    }
    return _imgView;
}

- (CTVideoPlayView *)videoPlayView {
    if (!_videoPlayView) {
        _videoPlayView = [[CTVideoPlayView alloc] initWithFrame:CGRectMake(-5, 0, self.frame.size.width, self.frame.size.height)];
        [self.imgView addSubview:_videoPlayView];
    }
    return _videoPlayView;
}
@end
