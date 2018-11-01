//
//  GroupAlbumViewController.m
//
//  Created by 腾 on 15/9/15.
//
//

#import "CTPhotosCollectionViewController.h"
#import "CTPhotosCollectionViewCell.h"
#import "CTPreviewPhotosCollectionViewController.h"
#import "PHAssetCollection+CTAssetCollectionManager.h"
#import "PHAsset+CTPHAssetManager.h"
#import "CTPhotoManager.h"
#import "CTCutImageController.h"
#import "CTTakePhotoController.h"

NSString *const  kCTPhotosBottomReusableView = @"kCTPhotosBottomReusableView";
NSString *const  kCTTakePhotoCellIdentifier = @"kCTTakePhotoCellIdentifier";

CGFloat const FOOTER_HEIGHT = 40;
#define kPhotoCellWidth   ([[UIScreen mainScreen] bounds].size.width-5)/4

@interface CTPhotosCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *ColView;
@property (nonatomic, strong) UILabel *footerLabel;//相片数量
@property (nonatomic, strong) CTCollectionModel *collectionModel;
@property (nonatomic, strong) CTBottomView * bottomBar;//底部信息
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) BOOL isShowCamera;

@end

@implementation CTPhotosCollectionViewController
#pragma mark ------------------------------------ life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = self.collection.localizedTitle;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self p_updateNavigationBar];

    if (!CTPhotosConfiguration.chooseHead&&!CTPhotosConfiguration.oneChoose) {
        [self p_blockActions];
    }
    
    [self p_fetchAssetsData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}
#pragma mark ------------------------------------ private
//获取相册所有照片的数据
- (void)p_fetchAssetsData {
    
    PHFetchResult *result = [self.collection fetchCollectionAssets];
    for (PHAsset *asset in result) {
        if (asset.mediaType==PHAssetMediaTypeImage) {
            CTPHAssetModel *model = [CTPHAssetModel initWithAsset:asset];
            [self.collectionModel.albumArray addObject:model];
        }
        if (CTPhotosConfiguration.showVideo&&asset.mediaType==PHAssetMediaTypeVideo) {
            CTPHAssetModel *model = [CTPHAssetModel initWithAsset:asset];
            [self.collectionModel.albumArray addObject:model];
        }
    }
    if (CTPhotosConfiguration.chooseHead||CTPhotosConfiguration.oneChoose||_collectionModel.albumArray.count==0) {
        _isShowCamera = YES;
    }
    [self.ColView reloadData];
    //滚动到最底部
    NSInteger index = _isShowCamera?_collectionModel.albumArray.count:_collectionModel.albumArray.count-1;
    [self.ColView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (CTPhotosConfiguration.chooseHead||CTPhotosConfiguration.oneChoose) {
            CGRect frame = self.ColView.frame;
            frame.size.height = kDevice_height - NAVBAR_HEIGHT;
            self.ColView.frame = frame;
        }
    });
}
//按钮动作
- (void)p_blockActions {
    
    WEAKSELF;
    //预览
    [self.bottomBar.previewBtn blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender) {
        weakSelf.collectionModel.currenIndex = 0;

        CTPreviewPhotosCollectionViewController *preview = [CTPreviewPhotosCollectionViewController new];
        preview.collectionModel = weakSelf.collectionModel;
        preview.photoBlock = weakSelf.photoBlock;
        WEAKSELF;
        preview.refreshBlock = ^{
            [weakSelf.ColView reloadData];
            [weakSelf p_refreshBottomBtn];
        };
        preview.isPreviewModel = YES;
        [self.navigationController pushViewController:preview animated:YES];
    }];
    //原图切换
    [self.bottomBar.originBtn blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender) {
        weakSelf.collectionModel.sendOriginImg = !weakSelf.collectionModel.sendOriginImg;
        weakSelf.bottomBar.originBtn.selected = weakSelf.collectionModel.sendOriginImg;
        NSString *totalSize = nil;
        if (weakSelf.collectionModel.sendOriginImg) {
            totalSize = [self.collectionModel calucateImagesSize];
        }
        self.bottomBar.imageSizeLabel.text = totalSize;
    }];
    //发送图片
    [self.bottomBar.senderBtn blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender) {
        [weakSelf.indicatorView startAnimating];
        [CTPhotoManager sendImageData:weakSelf.collectionModel imagesBlock:^(NSArray<CTPHAssetModel *> *imagesArray) {
            [weakSelf.indicatorView stopAnimating];
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            if (CTPhotoManager.delegate&&[CTPhotoManager.delegate respondsToSelector:@selector(sendImageArray:)]) {
                [CTPhotoManager.delegate sendImageArray:imagesArray];
            }
            if (weakSelf.photoBlock) {
                weakSelf.photoBlock(imagesArray);
            }
        }];
    }];
}
//刷新发送按钮
- (void)p_refreshBottomBtn {
    [self.bottomBar.senderBtn setTitle:self.collectionModel.sendBtnTitle forState:UIControlStateNormal];
    self.bottomBar.senderBtn.enabled = self.collectionModel.selectedArray.count;
    if (self.bottomBar.senderBtn.enabled) {
        self.bottomBar.senderBtn.backgroundColor = kMAINCOLOR;
    }else {
        self.bottomBar.senderBtn.backgroundColor = kColorValue(0xD8DBE4);
    }
    self.bottomBar.previewBtn.enabled = self.collectionModel.selectedArray.count;
    self.bottomBar.originBtn.selected = self.collectionModel.sendOriginImg;

    NSString *totalSize = nil;
    if (self.collectionModel.sendOriginImg) {
        totalSize = [self.collectionModel calucateImagesSize];
    }
    self.bottomBar.imageSizeLabel.text = totalSize;
}
- (void)p_backToPreVC {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}
- (void)p_backaction {
    [self.navigationController popViewControllerAnimated:YES];
}
//导航栏样式
- (void)p_updateNavigationBar {

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    [btn setImage:kImage(@"back_black", 25, 25) forState:UIControlStateNormal];

    [btn addTarget:self action:@selector(p_backaction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIButton *rightBtn = [UIButton new];
    [rightBtn sizeToFit];
    [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = kSystemFont(16);
    [rightBtn setTitleColor:kMAINCOLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(p_backToPreVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}

#pragma mark ------------------------------------ UICollectionViewDelegate UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger index = _isShowCamera?_collectionModel.albumArray.count+1:_collectionModel.albumArray.count;
    return index;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *mycell;
    if (indexPath.row<_collectionModel.albumArray.count) {
        mycell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CTPhotosCollectionViewCell class]) forIndexPath:indexPath];
    }else {
        mycell = [collectionView dequeueReusableCellWithReuseIdentifier:kCTTakePhotoCellIdentifier forIndexPath:indexPath];
        [mycell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
        icon.image = kImage(@"takePhoto",25,25);
        icon.center = CGPointMake(kPhotoCellWidth/2, kPhotoCellWidth/2-10);
        [mycell addSubview:icon];
        
        UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(0, kPhotoCellWidth/2+10, kPhotoCellWidth, 20)];
        tip.textAlignment = NSTextAlignmentCenter;
        tip.font = [UIFont systemFontOfSize:12];
        tip.textColor = UIColor.lightGrayColor;
        tip.text = @"拍摄照片";
        [mycell addSubview:tip];
        mycell.backgroundColor = kColorValue(0xF5F5F5);
    }
    if (CTPhotosConfiguration.chooseHead||CTPhotosConfiguration.oneChoose) {
        return mycell;
    }
    //注册3D Touch
    /**
     从iOS9开始，我们可以通过这个类来判断运行程序对应的设备是否支持3D Touch功能。
     UIForceTouchCapabilityUnknown = 0,     //未知
     UIForceTouchCapabilityUnavailable = 1, //不可用
     UIForceTouchCapabilityAvailable = 2    //可用
     */
    if ([self respondsToSelector:@selector(traitCollection)]&&[mycell isKindOfClass:CTPhotosCollectionViewCell.class]) {
        if (@available(iOS 9.0, *)) {
            if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
                if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable ) {
                    [self registerForPreviewingWithDelegate:(id)self sourceView:mycell];
                }
            }
        }
    }
    
    return mycell;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row==_collectionModel.albumArray.count) {
        return;
    }
    CTPHAssetModel *model = self.collectionModel.albumArray[indexPath.row];
    CTPhotosCollectionViewCell *mycell = (CTPhotosCollectionViewCell *)cell;
    
    [mycell processData:model indexPath:indexPath showFrame:NO];
    //单元格选择动作
    WEAKSELF;
    [mycell.selectBut blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender) {
        CTPHAssetModel *model = weakSelf.collectionModel.albumArray[sender.tag];
        
        //超出最大选择数 弹出提示
        if (!model.selected&&weakSelf.collectionModel.selectedArray.count==CTPhotosConfiguration.maxNum) {
            [weakSelf presentAlertController:CTPhotosConfiguration.maxNum];
            return;
        }
        //正在下载
        if (model.downloading) {
            return;
        }
        //原图不在本地
        if (![model checkLocalAsset]) {
            //需要下载图片
            [mycell showDownloadView];
            [model downLoadMediaFromiCloud];
            return;
        }
        model.selected = !model.selected;
        mycell.selectBut.selected = model.selected;
        mycell.backView.hidden = !model.selected;
        if (model.selected) {
            [mycell.selectBut showAnimation];
            if (![weakSelf.collectionModel.selectedArray containsObject:model]) {
                [weakSelf.collectionModel.selectedArray addObject:model];
            }
        }else{
            if ([weakSelf.collectionModel.selectedArray containsObject:model]) {
                [weakSelf.collectionModel.selectedArray removeObject:model];
            }
        }
        [weakSelf.collectionModel refreshSelectedDataNumber];
        if (model.selected) {
            [mycell.selectBut setTitle:model.chooseNum forState:UIControlStateSelected];
        }
       //刷新序号
        NSMutableArray <NSIndexPath *> *indexArray = [NSMutableArray new];
        for (CTPHAssetModel *chooseModel in weakSelf.collectionModel.selectedArray) {
            if (chooseModel == model) {
                continue;
            }
            [indexArray addObject:chooseModel.indexPath];
        }
        [weakSelf.ColView reloadItemsAtIndexPaths:indexArray];
        weakSelf.collectionModel.previewArray = weakSelf.collectionModel.selectedArray.copy;
        [weakSelf p_refreshBottomBtn];
    }];
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //拍照
    if (indexPath.row==_collectionModel.albumArray.count) {
        //相机
        if (![CTSavePhotos checkAuthorityOfCamera]) {
            return;
        }
        CTTakePhotoButtomViewModel takeModel;
        if(!CTPhotosConfiguration.showVideo) {
            takeModel = CTTakePhotoModel;
        }else {
            takeModel = CTTakePhotoAndVideoModel;
        }
        [CTTakePhotoController showTakePhotoOrVideo:takeModel
                                         isCutImage:CTPhotosConfiguration.chooseHead
                                              block:^(UIImage *takeImage, NSString *videoLocalPath) {
                                                  CTPHAssetModel *model = CTPHAssetModel.new;
                                                  model.sendImage = takeImage;
                                                  if (videoLocalPath) {
                                                      model.videoLocalPath = videoLocalPath;
                                                      model.isVideo = YES;
                                                  }else {
                                                      model.imageData = UIImageJPEGRepresentation(takeImage, CTPhotosConfiguration.outputPhotosScale);
                                                  }
                                                  if (self.presentingViewController) {
                                                      [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                  }else {
                                                      [self dismissViewControllerAnimated:YES completion:nil];
                                                  }
                                                  if (CTPhotoManager.delegate&&[CTPhotoManager.delegate respondsToSelector:@selector(sendImageArray:)]) {
                                                      [CTPhotoManager.delegate sendImageArray:@[model]];
                                                  }
                                                  if (self.photoBlock) {
                                                      self.photoBlock(@[model]);
                                                  }
                                              }];
        return;
    }
    if (CTPhotosConfiguration.chooseHead||CTPhotosConfiguration.oneChoose) {
        CTPHAssetModel *model = self.collectionModel.albumArray[indexPath.row];
        //正在下载
        if (model.downloading) {
            return;
        }
        //原图不在本地
        if (![model checkLocalAsset]) {
            CTPhotosCollectionViewCell *mycell = (CTPhotosCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
            //需要下载图片
            [mycell showDownloadView];
            [model downLoadMediaFromiCloud];
            return;
        }
        [self.collectionModel.selectedArray addObject:model];

        [self.indicatorView startAnimating];
        [CTPhotoManager sendImageData:self.collectionModel imagesBlock:^(NSArray<CTPHAssetModel *> *imagesArray) {
            [self.indicatorView stopAnimating];
            if (CTPhotosConfiguration.oneChoose) {
                [self dismissViewControllerAnimated:YES completion:nil];
                if (CTPhotoManager.delegate&&[CTPhotoManager.delegate respondsToSelector:@selector(sendImageArray:)]) {
                    [CTPhotoManager.delegate sendImageArray:imagesArray];
                }
                if (self.photoBlock) {
                    self.photoBlock(imagesArray);
                }
            }else {
                CTCutImageController *cutVc = CTCutImageController.new;
                cutVc.image = model.sendImage;
                cutVc.model = model;
                cutVc.photoBlock = self.photoBlock;
                [self.collectionModel.selectedArray removeAllObjects];
                [self.navigationController pushViewController:cutVc animated:true];
            }
        }];
        return;
    }
    self.collectionModel.currenIndex = indexPath.row;
    CTPreviewPhotosCollectionViewController *preview = [CTPreviewPhotosCollectionViewController new];
    preview.collectionModel = self.collectionModel;
    preview.photoBlock = self.photoBlock;
    WEAKSELF;
    preview.refreshBlock = ^{
        [weakSelf.ColView reloadData];
        [weakSelf p_refreshBottomBtn];
    };
    preview.currenIndex = indexPath.row;
    [self.navigationController pushViewController:preview animated:YES];
    
}
//设置footerView
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView * resuableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kCTPhotosBottomReusableView forIndexPath:indexPath];
    
    if (![resuableView.subviews containsObject:self.footerLabel]) {
        [resuableView addSubview:self.footerLabel];
    }
  
    return resuableView;
}
#pragma mark ------------------------------------ <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(kDevice_width, FOOTER_HEIGHT);
}
#pragma mark ------------------------------------ 3d Touch预览
- (UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location NS_AVAILABLE_IOS(9_0) {
    
    NSIndexPath *indexPath = [self.ColView indexPathForCell:(CTPhotosCollectionViewCell *)[previewingContext sourceView]];
    self.collectionModel.currenIndex = indexPath.row;

    CTPreviewPhotosCollectionViewController *preview = [CTPreviewPhotosCollectionViewController new];
    preview.collectionModel = self.collectionModel;
    preview.photoBlock = self.photoBlock;
    WEAKSELF;
    preview.refreshBlock = ^{
        [weakSelf.ColView reloadData];
        [weakSelf p_refreshBottomBtn];
    };
    preview.preview3D = YES;
    preview.currenIndex = indexPath.row;
    return preview;
}
- (void)previewingContext:(id )previewingContext commitViewController:(UIViewController *)viewControllerToCommit NS_AVAILABLE_IOS(9_0) {
    [self showViewController:viewControllerToCommit sender:self];
}

#pragma mark ------------------------------------ lazy
- (UICollectionView *)ColView {
    if (_ColView ==nil) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.sectionInset =  UIEdgeInsetsMake(1, 1, 1, 1);
        layout.minimumLineSpacing = 1.0;
        layout.minimumInteritemSpacing = 1.0;
        layout.itemSize = CGSizeMake(kPhotoCellWidth, kPhotoCellWidth);
      
        _ColView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, kDevice_width, kDevice_height-self.bottomBar.frame.size.height-NAVBAR_HEIGHT) collectionViewLayout:layout];
        if (![UINavigationBar appearance].translucent) {
            _ColView.frame = CGRectMake(0, 0, kDevice_width, kDevice_height-self.bottomBar.frame.size.height-NAVBAR_HEIGHT);
        }
        _ColView.delegate = self;
        _ColView.dataSource = self;
        _ColView.alwaysBounceVertical = YES;
        _ColView.backgroundColor= [UIColor groupTableViewBackgroundColor];
        [_ColView registerClass:[CTPhotosCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([CTPhotosCollectionViewCell class])];
        [_ColView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:kCTTakePhotoCellIdentifier];
        [_ColView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kCTPhotosBottomReusableView];
        [self.view addSubview:_ColView];

    }
    return _ColView;
}

- (UILabel *)footerLabel {
    if (!_footerLabel) {
        _footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, kDevice_width-40, FOOTER_HEIGHT)];
        _footerLabel.numberOfLines = 0;
        _footerLabel.font = [UIFont systemFontOfSize:15];
        _footerLabel.textColor = [UIColor lightGrayColor];
        _footerLabel.textAlignment = NSTextAlignmentCenter;
        if (!CTPhotosConfiguration.showVideo) {
            _footerLabel.text = [NSString stringWithFormat:@"共%lu张照片",(unsigned long)self.collectionModel.albumArray.count];
        }else {
            NSInteger videoNum = 0;
            for (CTPHAssetModel *model in _collectionModel.albumArray) {
                if (model.isVideo) {
                    videoNum++;
                }
            }
            NSInteger photoNum = _collectionModel.albumArray.count-videoNum;
            _footerLabel.text = [NSString stringWithFormat:@"共%ld张照片，%ld个视频",(long)photoNum,(long)videoNum];
        }
    }
    return _footerLabel;
}

- (CTBottomView *)bottomBar {
    if (_bottomBar == nil) {
        CGFloat height = iPhoneX ? 79 : 44;
        _bottomBar = [[CTBottomView alloc] initWithFrame:CGRectMake(0, kDevice_height-height- NAVBAR_HEIGHT, self.view.bounds.size.width, height)];
        _bottomBar.backgroundColor = kColorValue(0xFFFFFF);

        [self.view addSubview:_bottomBar];
    }
    
    return _bottomBar;
}

- (CTCollectionModel *)collectionModel{
    if (!_collectionModel) {
        _collectionModel = [CTCollectionModel new];
    }
    return _collectionModel;
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
