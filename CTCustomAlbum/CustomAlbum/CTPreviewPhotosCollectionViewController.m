//
//  BigCollectionViewController.m
//
//  Created by Apple on 16/7/22.
//  Copyright © 2016年 深圳太极云软技术股份有限公司. All rights reserved.
//

#import "CTPreviewPhotosCollectionViewController.h"
#import "CTPhotoManager.h"

@interface CTPreviewPhotosCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,CTImageScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *colView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;//菊花
@property (nonatomic, strong) UIView * topBar;//顶部视图 懒加载
@property (nonatomic, strong) UIButton *selectBut;//选择按钮
@property (nonatomic, strong) UIButton *backBtn;//返回按钮
@property (nonatomic, strong) CTBottomView * bottomBar;//底部视图
@property (nonatomic, assign) BOOL isHiddenTop;//是否隐藏工具栏

@end

static NSString *kPreviewCollectionCellIdengifier = @"kPreviewCollectionCellIdengifier";

@implementation CTPreviewPhotosCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.colView setContentOffset:CGPointMake((Device_width+20)*self.collectionModel.currenIndex, 0)];

    [self p_blockActions];

    [self p_refreshSendBtn];
    self.automaticallyAdjustsScrollViewInsets = NO;

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    if (_preview3D) {
        //3D touch进入该界面 需要自动滚动到相应位置
        [self.colView setContentOffset:CGPointMake((Device_width+20)*self.collectionModel.currenIndex, 0)];

        [self.view sendSubviewToBack:self.colView];
    }
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
//按钮回调
- (void)p_blockActions{
    
    WEAKSELF;
    [self.backBtn blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    //右上角选择按钮
    [self.selectBut blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender) {
       
        CTPHAssetModel *model = weakSelf.collectionModel.albumArray[weakSelf.currenIndex];
        if (!model.selected&&weakSelf.collectionModel.selectedArray.count==CTPhotosConfiguration.maxNum) {
            [weakSelf presentAlertController:CTPhotosConfiguration.maxNum];
            
            return;
        }

        if (!model.originImg) {
            return;
        }
        model.selected = !model.selected;
        weakSelf.selectBut.selected = model.selected;
        if (model.selected) {
            [weakSelf.selectBut showAnimation];
            [weakSelf.collectionModel addSelectedIndex:weakSelf.currenIndex];
            
        }else{
            [weakSelf.collectionModel removeSelectedIndex:weakSelf.currenIndex];
        }
        [weakSelf p_refreshSendBtn];
    }];
    
    //原图切换
    [self.bottomBar.originBtn blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender){
        weakSelf.collectionModel.sendOriginImg = !weakSelf.collectionModel.sendOriginImg;

        [weakSelf p_refreshSendBtn];

    }];
    
    //发送图片
    [self.bottomBar.senderBtn blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender) {
        [weakSelf.activityView startAnimating];
        [CTPhotoManager sendImageData:weakSelf.collectionModel imagesBlock:^(NSArray<UIImage *> *imagesArray) {
            if (CTPhotoManager.delegate&&[CTPhotoManager.delegate respondsToSelector:@selector(sendImageArray:)]) {
                [CTPhotoManager.delegate sendImageArray:imagesArray];
            }
            
            if (weakSelf.photoBlock) {
                weakSelf.photoBlock(imagesArray);
            }
            [weakSelf.activityView stopAnimating];
            
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
     
    }];

}
//刷新发送按钮
- (void)p_refreshSendBtn{
    [self.bottomBar.senderBtn setTitle:self.collectionModel.sendBtnTitle forState:UIControlStateNormal];
    
    self.bottomBar.senderBtn.enabled = self.collectionModel.selectedArray.count;
    NSString *totalSize = nil;
    if (self.collectionModel.sendOriginImg) {
        totalSize = [self.collectionModel calucateImagesSize];
    }
    self.bottomBar.imageSizeLabel.text = totalSize;
    self.bottomBar.originBtn.selected = self.collectionModel.sendOriginImg;

}

#pragma mark UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectionModel.albumArray.count;
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    UICollectionViewCell *mycell = [collectionView dequeueReusableCellWithReuseIdentifier:kPreviewCollectionCellIdengifier forIndexPath:indexPath];
    [mycell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CTPHAssetModel *model = self.collectionModel.albumArray[indexPath.row];
    
    CGRect frame;
    if (IPhoneX) {
        frame  = CGRectMake(0, 0, Device_width,self.colView.frame.size.height+10);
    }else{
        frame  = CGRectMake(0, 10, Device_width,self.colView.frame.size.height);

    }
    CTPrviewImageScrollView *scrView = [[CTPrviewImageScrollView alloc] initWithFrame:frame];
    scrView.scrolDelegate = self;
    [mycell.contentView addSubview:scrView];

    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    activityView.center = CGPointMake(mycell.frame.size.width/2, mycell.frame.size.height/2);
    [activityView startAnimating];
    activityView.hidesWhenStopped = YES;
    activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [mycell.contentView addSubview:activityView];
    model.downloading = YES;
    
    // 默认大小
    [model.asset fetchPreviewImageComplete:^(UIImage * _Nullable thumbImg,NSDictionary * _Nullable info) {
        [scrView refreshShowImage:thumbImg];
        
        //判断是否为原图
        BOOL imgDegrade = [info[PHImageResultIsDegradedKey] boolValue];
        if (!imgDegrade) {
            [activityView stopAnimating];
            model.originImg = YES;
            model.downloading = NO;
        }
    }];

    return mycell;
}

#pragma mark 正在滑动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSInteger pageNum = (scrollView.contentOffset.x - (Device_width+20) / 2) / (Device_width+20) + 1;
    _currenIndex = pageNum;
    
    CTPHAssetModel *model = self.collectionModel.albumArray[_currenIndex];
    self.selectBut.selected = model.selected;

}
#pragma mark CTImageScrollViewDelegate 点击隐藏
- (void)singalTapAction{
    _isHiddenTop = !_isHiddenTop;
    [[UIApplication sharedApplication] setStatusBarHidden:_isHiddenTop];

    [UIView animateWithDuration:0.25 animations:^{
   
        self.topBar.alpha = !_isHiddenTop;
        self.bottomBar.alpha = !_isHiddenTop;
   
    }];
}

#pragma mark ---lazy method
- (UICollectionView *)colView{
    if (!_colView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(Device_width+10, Device_height);
        layout.sectionInset = UIEdgeInsetsMake(-20, 0, 0, 10);
        
        CGRect colFrame = CGRectMake(0, 0, Device_width+20, Device_height);
        if (IPhoneX) {
            colFrame = CGRectMake(0, 0, Device_width+20, Device_height+5);
        }
        _colView = [[UICollectionView alloc] initWithFrame:colFrame collectionViewLayout:layout];
        _colView.pagingEnabled = YES;
        _colView.delegate = self;
        _colView.dataSource = self;
        _colView.backgroundColor = [UIColor whiteColor];
        _colView.directionalLockEnabled  = YES;
        
        [_colView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kPreviewCollectionCellIdengifier];
        [self.view addSubview:_colView];

    }
    return _colView;
}
- (UIView *)topBar
{
    if (!_topBar){
        _topBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, NAVBAR_HEIGHT)];
        
        _topBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        
        [self.view addSubview:_topBar];
    }
    
    return _topBar;
}
- (UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, NAVBAR_HEIGHT-44, 60, 44)];
        _backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
        [_backBtn setImage:[UIImage imageNamed:@"ctCustomback"] forState:UIControlStateNormal];
        [self.topBar addSubview:_backBtn];
    }
    return _backBtn;
}
- (CTBottomView *)bottomBar
{
    if (!_bottomBar){
        CGFloat height = IPhoneX ? 79 : 44;

        _bottomBar = [[CTBottomView alloc] initWithFrame:CGRectMake(0, Device_height - height, self.view.bounds.size.width, height)];

        _bottomBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];

        [self.view addSubview:_bottomBar];
    }
    
    return _bottomBar;
}
- (UIButton *)selectBut{
    if (!_selectBut) {
        _selectBut = [[UIButton alloc] initWithFrame:CGRectMake(Device_width-54, NAVBAR_HEIGHT-44, 44, 44)];
        [_selectBut setImage:[UIImage imageNamed:@"ct_punselect"] forState:UIControlStateNormal];
        [_selectBut setImage:[UIImage imageNamed:@"ct_pselected"] forState:UIControlStateSelected];
        [self.topBar addSubview:_selectBut];
    }
    return _selectBut;
}

- (UIActivityIndicatorView *)activityView{
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityView.frame = CGRectMake(0, 0, 50, 50);
        _activityView.center = self.colView.center;
        _activityView.hidesWhenStopped = YES;
        [self.view addSubview:_activityView];
    }
    
    return _activityView;
}
@end
