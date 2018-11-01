//
//  BigCollectionViewController.m
//
//  Created by Apple on 16/7/22.
//  Copyright © 2016年 深圳太极云软技术股份有限公司. All rights reserved.
//

#import "CTPreviewPhotosCollectionViewController.h"
#import "CTPhotoManager.h"
#import "CTPreviewCollectionViewCell.h"
#import "CTPreviewImageView.h"

NSInteger KHiddenTooltime = 5;

@interface CTPreviewPhotosCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,CTPreviewCollectionViewCellDelegate>

@property (nonatomic, strong) UICollectionView *colView;
@property (nonatomic, strong) UIView * topBar;//顶部视图 懒加载
@property (nonatomic, strong) UIButton *selectBut;//选择按钮
@property (nonatomic, strong) UIButton *backBtn;//返回按钮
@property (nonatomic, strong) CTBottomView * bottomBar;//底部视图
@property (nonatomic, strong) CTPreviewImageView *preview;//图片预览
@property (nonatomic, assign) BOOL isHiddenTop;//是否隐藏工具栏
@property (nonatomic, assign) NSInteger preIndex;//滚动结束之前的序号
@property (nonatomic ,strong) NSArray <CTPHAssetModel *> *previewArray;//预览数据源
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation CTPreviewPhotosCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;

    if (_isPreviewModel) {
        _previewArray = self.collectionModel.previewArray;
        self.selectBut.selected = YES;
        [self.selectBut setTitle:_previewArray[0].chooseNum forState:UIControlStateSelected];
    }else {
        _previewArray = self.collectionModel.albumArray;
    }
    [self.colView setContentOffset:CGPointMake((kDevice_width+20)*self.collectionModel.currenIndex, 0)];
    [self.view sendSubviewToBack:self.colView];
 
    [self p_blockActions];
    [self p_refreshSendBtn];
    
    _preIndex = _currenIndex;
    if (_previewArray[_currenIndex].isVideo) {
        [self.timer fire];
    }
    if (self.collectionModel.selectedArray.count>0) {
        self.preview.hidden = NO;
        CTPHAssetModel *model = _previewArray[self.collectionModel.currenIndex];
        [self.preview refreshData:model];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

    if (_preview3D) {
        //3D touch进入该界面 需要自动滚动到相应位置
        [self.colView setContentOffset:CGPointMake((kDevice_width+20)*self.collectionModel.currenIndex, 0)];
        [self.view sendSubviewToBack:self.colView];
    }
 
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
#pragma mark ------------------------------------ private
//按钮回调
- (void)p_blockActions {
  
    WEAKSELF;
    [self.backBtn blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    //右上角选择按钮
    [self.selectBut blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender) {
       
        CTPHAssetModel *model = weakSelf.previewArray[weakSelf.currenIndex];
        if (!model.selected&&weakSelf.collectionModel.selectedArray.count==CTPhotosConfiguration.maxNum) {
            [weakSelf presentAlertController:CTPhotosConfiguration.maxNum];
            return;
        }

        if (![model checkLocalAsset]) {
            return;
        }
        model.selected = !model.selected;
        weakSelf.selectBut.selected = model.selected;
        if (model.selected) {
            [weakSelf.selectBut showAnimation];
            if (![weakSelf.collectionModel.selectedArray containsObject:model]) {
                [weakSelf.collectionModel.selectedArray addObject:model];
            }
        }else{
            if ([weakSelf.collectionModel.selectedArray containsObject:model]) {
                [weakSelf.collectionModel.selectedArray removeObject:model];
            }
        }
        weakSelf.collectionModel.previewArray = weakSelf.collectionModel.selectedArray.copy;
        [weakSelf.collectionModel refreshSelectedDataNumber];
        for (CTPHAssetModel *sModel in weakSelf.collectionModel.selectedArray) {
            if (sModel == model) {
                [weakSelf.selectBut setTitle:sModel.chooseNum forState:UIControlStateSelected];
            }
        }
        [weakSelf p_refreshSendBtn];
        [UIView animateWithDuration:0.25 animations:^{
            if (weakSelf.collectionModel.selectedArray.count==0) {
                weakSelf.preview.alpha = 0.0;
            }else {
                if (weakSelf.preview.alpha == 0.0) {
                    weakSelf.preview.alpha = 1.0;
                }
            }
            
        }];
        [weakSelf.preview refreshData:model];
        if (weakSelf.refreshBlock) {
            weakSelf.refreshBlock();
        }
    }];
    
    //原图切换
    [self.bottomBar.originBtn blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender){
        weakSelf.collectionModel.sendOriginImg = !weakSelf.collectionModel.sendOriginImg;
        [weakSelf p_refreshSendBtn];
    }];
    
    //发送图片
    [self.bottomBar.senderBtn blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender) {
        [self.indicatorView startAnimating];
        [CTPhotoManager sendImageData:weakSelf.collectionModel imagesBlock:^(NSArray<CTPHAssetModel *> *imagesArray) {
            [self.indicatorView stopAnimating];

            if (CTPhotoManager.delegate&&[CTPhotoManager.delegate respondsToSelector:@selector(sendImageArray:)]) {
                [CTPhotoManager.delegate sendImageArray:imagesArray];
            }
            
            if (weakSelf.photoBlock) {
                weakSelf.photoBlock(imagesArray);
            }
            
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
     
    }];

}
//刷新发送按钮
- (void)p_refreshSendBtn {
    [self.bottomBar.senderBtn setTitle:self.collectionModel.sendBtnTitle forState:UIControlStateNormal];
    self.bottomBar.senderBtn.enabled = self.collectionModel.selectedArray.count;
    if (self.bottomBar.senderBtn.enabled) {
        self.bottomBar.senderBtn.backgroundColor = kMAINCOLOR;
    }else {
        self.bottomBar.senderBtn.backgroundColor = kColorValue(0xD8DBE4);
    }
    NSString *totalSize = nil;
    if (self.collectionModel.sendOriginImg) {
        totalSize = [self.collectionModel calucateImagesSize];
    }
    self.bottomBar.imageSizeLabel.text = totalSize;
    self.bottomBar.originBtn.selected = self.collectionModel.sendOriginImg;
}
- (void)p_hiddenToolView {
    [_timer invalidate];
    _timer = nil;
    _isHiddenTop = YES;
    for (CTPreviewCollectionViewCell *cell in self.colView.visibleCells) {
        [cell hiddenVideoIcon];
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.windowLevel = UIWindowLevelAlert;
    [UIView animateWithDuration:0.1 animations:^{
        self.topBar.alpha = 0;
        self.bottomBar.alpha = 0;
        self.preview.alpha = 0;
    }];
}
#pragma mark ------------------------------------ UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _previewArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    CTPreviewCollectionViewCell *mycell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CTPreviewCollectionViewCell class]) forIndexPath:indexPath];
    mycell.delegate = self;
    return mycell;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    CTPHAssetModel *model = _previewArray[indexPath.row];

    [(CTPreviewCollectionViewCell *)cell processData:model indexPath:indexPath];
}
#pragma mark ------------------------------------ UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSInteger pageNum = (scrollView.contentOffset.x + (kDevice_width+20) / 2) / (kDevice_width+20);
    _currenIndex = pageNum;
    
    CTPHAssetModel *model = _previewArray[_currenIndex];
    self.selectBut.selected = model.selected;
    [self.selectBut setTitle:model.chooseNum forState:UIControlStateSelected];
    [_timer invalidate];
    _timer = nil;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_preIndex !=_currenIndex) {
        for (CTPreviewCollectionViewCell *mycell in self.colView.subviews) {
            if ([mycell isKindOfClass:[CTPreviewCollectionViewCell class]]) {
                [mycell stopPlay];
            }
        }
        _preIndex = _currenIndex;
    }
    CTPHAssetModel *model = _previewArray[_currenIndex];
    if (model.isVideo) {
        [self.timer fire];
    }else{
        [_timer invalidate];
        _timer = nil;
    }
    if ([self.collectionModel.selectedArray containsObject:model]) {
        [self.preview refreshData:model];
    }

}
#pragma mark ------------------------------------ CTImageScrollViewDelegate
- (void)singalTapAction {
    
    _isHiddenTop = !_isHiddenTop;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (_isHiddenTop) {
        window.windowLevel = UIWindowLevelAlert;
        [_timer invalidate];
        _timer = nil;
    }else {
        window.windowLevel = UIWindowLevelNormal;
        CTPHAssetModel *model = _previewArray[_currenIndex];
        if (model.isVideo) {
            [self.timer fire];
        }
    }
    [UIView animateWithDuration:0.1 animations:^{
        self.topBar.alpha = !self.isHiddenTop;
        self.bottomBar.alpha = !self.isHiddenTop;
        if (self.collectionModel.selectedArray.count>0) {
            self.preview.alpha = !self.isHiddenTop;
        }
    }];
}

#pragma mark ------------------------------------ lazy
- (UICollectionView *)colView {
    if (!_colView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(kDevice_width+10, kDevice_height);
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 10);
        
        CGRect colFrame = CGRectMake(0, 0, kDevice_width+20, kDevice_height);
        _colView = [[UICollectionView alloc] initWithFrame:colFrame collectionViewLayout:layout];
        _colView.pagingEnabled = YES;
        _colView.delegate = self;
        _colView.dataSource = self;
        _colView.backgroundColor = [UIColor blackColor];
        _colView.directionalLockEnabled  = YES;
        [_colView registerClass:[CTPreviewCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([CTPreviewCollectionViewCell class])];

        [self.view addSubview:_colView];
    }
    return _colView;
}
- (CTPreviewImageView *)preview {
    if (!_preview) {
        CGRect frame = CGRectMake(0, kDevice_height-self.bottomBar.frame.size.height-kPreviewImageHeight, kDevice_width, kPreviewImageHeight);
        _preview = [CTPreviewImageView initWithFrame:frame dataSource:self.collectionModel.selectedArray];
        WEAKSELF;
        _preview.didCellBlock = ^(CTPHAssetModel *model) {
            NSInteger curruntIndex = [weakSelf.previewArray indexOfObject:model];
            weakSelf.collectionModel.currenIndex = curruntIndex;
            for (CTPreviewCollectionViewCell *mycell in weakSelf.colView.subviews) {
                if ([mycell isKindOfClass:[CTPreviewCollectionViewCell class]]) {
                    [mycell stopPlay];
                }
            }
            [weakSelf.colView setContentOffset:CGPointMake((kDevice_width+20)*curruntIndex, 0) animated:NO];
        };
        [self.view addSubview:_preview];
    }
    return _preview;
                    
}
- (UIView *)topBar {
    if (!_topBar){
        _topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, NAVBAR_HEIGHT)];
        _topBar.backgroundColor = [kColorValue(0x1A1A1A) colorWithAlphaComponent:0.8];
        [self.view addSubview:_topBar];
    }
    return _topBar;
}
- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, NAVBAR_HEIGHT-40, 40, 40)];
        [_backBtn setImage:kImage(@"back_white",25,25) forState:UIControlStateNormal];
        [self.topBar addSubview:_backBtn];
    }
    return _backBtn;
}
- (CTBottomView *)bottomBar {
    if (!_bottomBar){
        CGFloat height = iPhoneX ? 79 : 44;
        _bottomBar = [[CTBottomView alloc] initWithFrame:CGRectMake(0, kDevice_height - height, self.view.bounds.size.width, height)];
        _bottomBar.backgroundColor = kColorValue(0xFFFFFF);
        [self.view addSubview:_bottomBar];
        _bottomBar.previewBtn.hidden = YES;
        _bottomBar.originBtn.center = CGPointMake(40, _bottomBar.originBtn.center.y);
    }
    
    return _bottomBar;
}
- (UIButton *)selectBut {
    if (!_selectBut) {
        _selectBut = [[UIButton alloc] initWithFrame:CGRectMake(kDevice_width-50, NAVBAR_HEIGHT-32, 25, 25)];
        [_selectBut setBackgroundImage:kImage(@"origin_unselect",15,15) forState:UIControlStateNormal];
        [_selectBut setBackgroundImage:kImage(@"照片选中",15,15) forState:UIControlStateSelected];
        [_selectBut setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
        _selectBut.titleLabel.font = kSystemFont(12);
        [self.topBar addSubview:_selectBut];
    }
    return _selectBut;
}
- (NSTimer *)timer {
    if (!_timer) {
       __block NSInteger totalTime = KHiddenTooltime;
        WEAKSELF;
        _timer = [NSTimer CTScheduledTimerWithTimeInterval:1 repeats:YES block:^{
            if (!totalTime) {
                [weakSelf p_hiddenToolView];
            }
            totalTime--;
        }];
    }
    return _timer;
}

- (void)dealloc {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}
- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _indicatorView.center = CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height/2);
        _indicatorView.hidesWhenStopped = YES;
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [self.view addSubview:_indicatorView];
    }
    return _indicatorView;
}
@end
