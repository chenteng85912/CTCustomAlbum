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

NSString *const  kCTPhotosBottomReusableView = @"kCTPhotosBottomReusableView";

CGFloat const FOOTER_HEIGHT = 40;

@interface CTPhotosCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *ColView;

@property (nonatomic,strong) UILabel *footerLabel;//相片数量

@property (nonatomic,strong) CTCollectionModel *collectionModel;

@property (nonatomic, strong) UIActivityIndicatorView * activityView;

//底部信息
@property (nonatomic, strong) CTBottomView * bottomBar;

@end

@implementation CTPhotosCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = self.collection.localizedTitle;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self p_updateNavigationBar];

    [self p_blockActions];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(backToPreVC)];
    
    [self p_fetchAssetsData];

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self p_refreshBottomBtn];
    [self.ColView reloadData];
}
//按钮动作
- (void)p_blockActions{
    
    WEAKSELF;
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
//        [weakSelf.activityView startAnimating];
        
        [CTPhotoManager sendImageData:weakSelf.collectionModel imagesBlock:^(NSArray<UIImage *> *imagesArray) {
            //            [weakSelf.activityView stopAnimating];
            
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
- (void)p_refreshBottomBtn{
    [self.bottomBar.senderBtn setTitle:self.collectionModel.sendBtnTitle forState:UIControlStateNormal];
    self.bottomBar.senderBtn.enabled = self.collectionModel.selectedArray.count;

    self.bottomBar.originBtn.selected = self.collectionModel.sendOriginImg;

    NSString *totalSize = nil;
    if (self.collectionModel.sendOriginImg) {
        totalSize = [self.collectionModel calucateImagesSize];
    }
    self.bottomBar.imageSizeLabel.text = totalSize;
}
- (void)backToPreVC{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


//导航栏样式
- (void)p_updateNavigationBar{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}
#pragma mark UICollectionViewDelegate
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectionModel.albumArray.count;
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CTPhotosCollectionViewCell *mycell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CTPhotosCollectionViewCell class]) forIndexPath:indexPath];
    
    CTPHAssetModel *cellModel = self.collectionModel.albumArray[indexPath.row];

    [mycell processData:cellModel indexPath:indexPath];
    
    //单元格选择动作
    WEAKSELF;
    [mycell.selectBut blockWithControlEvents:UIControlEventTouchUpInside block:^(UIButton *sender) {
        CTPHAssetModel *model = self.collectionModel.albumArray[sender.tag];

        //超出最大选择数 弹出提示
        if (!model.selected&&weakSelf.collectionModel.selectedArray.count==CTPhotosConfiguration.maxNum) {
            [weakSelf presentAlertController:CTPhotosConfiguration.maxNum];
            
            return;
        }
        if (model.downloading) {
            return;
        }
        if (![model.asset checkLocalAsset]) {
            //需要下载图片
            [mycell showOrHiddenBackView:NO];

            [model downLoadImageFromiCloud:^{
                [mycell showOrHiddenBackView:YES];
            }];
            return;
        }
        model.selected = !model.selected;
        mycell.selectBut.selected = model.selected;
        if (model.selected) {
            [mycell.selectBut showAnimation];
            [weakSelf.collectionModel addSelectedIndex:indexPath.row];

        }else{
            [weakSelf.collectionModel removeSelectedIndex:indexPath.row];
        }
        [weakSelf p_refreshBottomBtn];
    }];
    //注册3D Touch
    /**
     从iOS9开始，我们可以通过这个类来判断运行程序对应的设备是否支持3D Touch功能。
     UIForceTouchCapabilityUnknown = 0,     //未知
     UIForceTouchCapabilityUnavailable = 1, //不可用
     UIForceTouchCapabilityAvailable = 2    //可用
     */
    if ([self respondsToSelector:@selector(traitCollection)]) {
        if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
            
            if (@available(iOS 9.0, *)) {
                if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable ) {
                    [self registerForPreviewingWithDelegate:(id)self sourceView:mycell];
                }
            }
        }
    }
    
   
    return mycell;
}

#pragma mark - UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.collectionModel.currenIndex = indexPath.row;

    CTPreviewPhotosCollectionViewController *preview = [CTPreviewPhotosCollectionViewController new];
    preview.collectionModel = self.collectionModel;
    preview.photoBlock = self.photoBlock;
    preview.currenIndex = indexPath.row;
    [self.navigationController pushViewController:preview animated:YES];
    
}
//设置footerView
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView * resuableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kCTPhotosBottomReusableView forIndexPath:indexPath];
    
    if (![resuableView.subviews containsObject:self.footerLabel]) {
        [resuableView addSubview:self.footerLabel];
    }
  
    return resuableView;
}
#pragma mark - <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(Device_width, FOOTER_HEIGHT);
}
//获取相册所有照片的数据
- (void)p_fetchAssetsData{
    
    PHFetchResult *result = [self.collection fetchCollectionAssets];
    for (PHAsset *asset in result) {
        if (asset.mediaType==PHAssetMediaTypeImage) {
            CTPHAssetModel *model = [CTPHAssetModel initWithAsset:asset];
            [self.collectionModel.albumArray addObject:model];
        }
    }
    [self.ColView reloadData];

    if (self.collectionModel.albumArray.count>0) {
        //滚动到最底部
        [self.ColView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.collectionModel.albumArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:false];
    }

}
//3d Touch预览
- (UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location NS_AVAILABLE_IOS(9_0){
    
    NSIndexPath *indexPath = [self.ColView indexPathForCell:(CTPhotosCollectionViewCell *)[previewingContext sourceView]];
    self.collectionModel.currenIndex = indexPath.row;

    CTPreviewPhotosCollectionViewController *preview = [CTPreviewPhotosCollectionViewController new];
    preview.collectionModel = self.collectionModel;
    preview.photoBlock = self.photoBlock;
    preview.preview3D = YES;
    preview.currenIndex = indexPath.row;
    return preview;
}
- (void)previewingContext:(id )previewingContext commitViewController:(UIViewController *)viewControllerToCommit NS_AVAILABLE_IOS(9_0) {

    [self showViewController:viewControllerToCommit sender:self];
}
#pragma mark 懒加载
- (UICollectionView *)ColView{
    if (_ColView ==nil) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.sectionInset =  UIEdgeInsetsMake(1, 1, 1, 1);
        layout.minimumLineSpacing = 1.0;
        layout.minimumInteritemSpacing = 1.0;
        layout.itemSize = CGSizeMake((Device_width-5)/4, (Device_width-5)/4);
      
        _ColView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, Device_width, Device_height-self.bottomBar.frame.size.height-NAVBAR_HEIGHT) collectionViewLayout:layout];
        if (![UINavigationBar appearance].translucent) {
            _ColView.frame = CGRectMake(0, 0, Device_width, Device_height-self.bottomBar.frame.size.height-NAVBAR_HEIGHT);
        }
        _ColView.delegate = self;
        _ColView.dataSource = self;
        _ColView.backgroundColor= [UIColor whiteColor];
        _ColView.alwaysBounceVertical = YES;
        [_ColView registerClass:[CTPhotosCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([CTPhotosCollectionViewCell class])];
        [_ColView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kCTPhotosBottomReusableView];
        _ColView.backgroundColor= [UIColor groupTableViewBackgroundColor];
        _ColView.alwaysBounceVertical = YES;
        [self.view addSubview:_ColView];

    }
    return _ColView;
}

- (UILabel *)footerLabel{
    if (!_footerLabel) {
        _footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, Device_width-40, FOOTER_HEIGHT)];
        _footerLabel.numberOfLines = 0;
        _footerLabel.font = [UIFont systemFontOfSize:15];
        _footerLabel.textColor = [UIColor lightGrayColor];
        _footerLabel.textAlignment = NSTextAlignmentCenter;
        _footerLabel.text = [NSString stringWithFormat:@"共有%lu张照片",(unsigned long)self.collectionModel.albumArray.count];
    }
    return _footerLabel;
}

- (CTBottomView *)bottomBar
{
    if (_bottomBar == nil)
    {
        CGFloat height = IPhoneX ? 79 : 44;
        
        _bottomBar = [[CTBottomView alloc] initWithFrame:CGRectMake(0, Device_height-height- NAVBAR_HEIGHT, self.view.bounds.size.width, height)];
    
        _bottomBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        [self.view addSubview:_bottomBar];
    }
    
    return _bottomBar;
}
- (UIActivityIndicatorView *)activityView{
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityView.frame = CGRectMake(0, 0, 50, 50);
        _activityView.center = self.ColView.center;
        _activityView.hidesWhenStopped = YES;
        [self.view addSubview:_activityView];
    }
    
    return _activityView;
}
- (CTCollectionModel *)collectionModel{
    if (!_collectionModel) {
        _collectionModel = [CTCollectionModel new];
    }
    return _collectionModel;
}

@end
