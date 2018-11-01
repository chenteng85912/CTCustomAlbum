//
//  AlbumCollectionViewCell.m
//
//  Created by 腾 on 15/9/16.
//
//

#import "CTPhotosCollectionViewCell.h"

@interface CTPhotosCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imgView;//缩略图
@property (nonatomic, strong) UIView *videoView;//视频标识
@property (nonatomic, strong) UILabel *videoDurationLabel;//视频长度
@property (nonatomic, strong) UIActivityIndicatorView *activityView;//下载菊花
@property (nonatomic, strong) UIView *dowloadView;//下载底图

@end

@implementation CTPhotosCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)processData:(CTPHAssetModel *)assetModel
          indexPath:(NSIndexPath *)indexPath
          showFrame:(BOOL)isShow {
    assetModel.delegate = self;
    self.imgView.image = nil;
    if (!isShow) {
        assetModel.indexPath = indexPath;
    }else {
        self.videoDurationLabel.font = kSystemFont(9);
        self.videoDurationLabel.frame = CGRectMake(self.frame.size.width-45, 0, 40, 20);
        UIImageView *video = [self.videoView viewWithTag:1001];
        video.frame = CGRectMake(5, 5, 16, 10);
    }
    self.selectBut.hidden = isShow;
    self.selectBut.selected = assetModel.selected;
    if (assetModel.selected) {
        [self.selectBut setTitle:assetModel.chooseNum forState:UIControlStateSelected];
    }else {
        self.selectBut.backgroundColor = [UIColor clearColor];
    }
    self.selectBut.tag = indexPath.row;
    
    if (!self.selectBut.hidden) {
        self.backView.hidden = !self.selectBut.selected;
    }else {
        self.backView.hidden = !assetModel.downloading;
    }
    if (assetModel.downloading) {
        self.dowloadView.hidden = NO;
        self.progressLabel.text = [NSString stringWithFormat:@"%.f%%",assetModel.progress*100];
        [self.activityView startAnimating];
    }else{
        self.dowloadView.hidden = YES;
        self.progressLabel.text = nil;
        [self.activityView stopAnimating];
    }
    self.videoView.hidden = !assetModel.isVideo;
    if (!self.videoView.hidden) {
        int duration = assetModel.asset.duration;
        self.videoDurationLabel.text = [NSString stringWithFormat:@"%02d:%02d",duration/60,duration%60];
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    WEAKSELF;
    [assetModel.asset fetchThumbImageWithSize:CGSizeMake(width/4, width/4) complete:^(UIImage * _Nullable img,NSDictionary * _Nullable info) {
        weakSelf.imgView.image = img;
    }];
    if (CTPhotosConfiguration.chooseHead||CTPhotosConfiguration.oneChoose) {
        self.selectBut.hidden = YES;
        self.videoView.hidden = YES;
        self.videoDurationLabel.hidden = YES;
    }
}
- (void)showDownloadView{
    self.dowloadView.hidden = NO;
    [self.activityView startAnimating];
}
#pragma mark ------------------------------------ CTPHAssetModelDelegate
- (void)downloadMedia:(double)progress {
    self.progressLabel.text = [NSString stringWithFormat:@"%.f%%",progress*100];
}
- (void)downloadSuccessOrFail:(BOOL)success {
    self.progressLabel.text = nil;
    [self.activityView stopAnimating];
    self.dowloadView.hidden = YES;
}
#pragma mark ------------------------------------ lazy
- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = true;
        [self.contentView addSubview:_imgView];
    }
    return _imgView;
}
- (UIButton *)selectBut {
    if (!_selectBut) {
        _selectBut = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-25,3, 22, 22)];
        [_selectBut setBackgroundImage:kImage(@"origin_unselect",10,10) forState:UIControlStateNormal];
        [_selectBut setBackgroundImage:kImage(@"照片选中",10,10) forState:UIControlStateSelected];
        [_selectBut setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
        _selectBut.titleLabel.font = kSystemFont(12);
        [self.contentView addSubview:_selectBut];
    }
    [self.contentView bringSubviewToFront:_selectBut];
    return _selectBut;
}
- (UIView *)videoView {
    if (!_videoView) {
        _videoView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-20, self.frame.size.width, 20)];
        _videoView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.3];
        UIImageView *video = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 16, 10)];
        video.tag = 1001;
        video.image = kImage(@"small_video",8,5);
        [_videoView addSubview:video];
        
        [self.contentView addSubview:_videoView];
    }
    return _videoView;
}
- (UILabel *)videoDurationLabel {
    if (!_videoDurationLabel) {
        _videoDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-50, 0, 40, 20)];
        _videoDurationLabel.font = kSystemFont(12);
        _videoDurationLabel.textAlignment = NSTextAlignmentRight;
        _videoDurationLabel.textColor = UIColor.whiteColor;
        [self.videoView addSubview:_videoDurationLabel];
    }
    return _videoDurationLabel;
}
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:self.bounds];
        _backView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        [self.contentView addSubview:_backView];
    }
    [self bringSubviewToFront:self.selectBut];
    return _backView;
}
- (UIView *)dowloadView {
    if (!_dowloadView) {
        _dowloadView = [[UIView alloc] initWithFrame:self.bounds];
        _dowloadView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _dowloadView.hidden = YES;
        [self.contentView addSubview:_dowloadView];
    }
    return _dowloadView;
}
- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2+5, self.frame.size.width, 20)];
        _progressLabel.font = kSystemFont(12);
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.textColor = UIColor.whiteColor;
        [self.dowloadView addSubview:_progressLabel];
    }
    return _progressLabel;
}

- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-20, self.frame.size.height/2-25, 40, 40)];
        [_activityView startAnimating];
        _activityView.hidesWhenStopped = YES;
        [self.dowloadView addSubview:_activityView];
    }
    return _activityView;
}
- (UIImageView *)frameView {
    if (!_frameView) {
        _frameView = [[UIImageView alloc] initWithFrame:self.bounds];
        _frameView.contentMode = UIViewContentModeScaleAspectFill;
        _frameView.image = [UIImage imageNamed:@"rectangle"];
        [self.contentView addSubview:_frameView];
    }
    return _frameView;
}
@end
