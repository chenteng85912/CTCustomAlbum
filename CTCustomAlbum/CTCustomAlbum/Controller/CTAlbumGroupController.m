//
//  AlbumViewController.m
//
//  Created by 腾 on 15/9/15.
//
//

#import "CTAlbumGroupController.h"
#import "CTGroupTableViewCell.h"
#import "CTPhotoManager.h"
#import "CTPhotosCollectionViewController.h"
#import "CTGroupModel.h"

@interface CTAlbumGroupController ()<PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) NSMutableArray <CTGroupModel *> *groupArray;//相册列表数组
@property (nonatomic, assign) BOOL needLoadAll;
@property (nonatomic, assign) BOOL isFirstLoad;

@end

@implementation CTAlbumGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"照片";
    [self p_initUI];
  
    //首次访问相册
    if (PHPhotoLibrary.authorizationStatus==PHAuthorizationStatusNotDetermined) {
        //注册实施监听相册变化
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        _isFirstLoad = YES;
    }else {
        if ([CTSavePhotos checkAuthorityOfAblum]) {
            [self p_fetchAllPhotos];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    //首次访问相册
    if (PHPhotoLibrary.authorizationStatus!=PHAuthorizationStatusNotDetermined) {
        if ([CTSavePhotos checkAuthorityOfAblum]) {
            [self p_fetchAllGroup];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 94;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CTGroupTableViewCell *mycell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CTGroupTableViewCell class]) forIndexPath:indexPath];
    
    [mycell processCellData:self.groupArray[indexPath.item]];

    return mycell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self p_showPhotosCollection:indexPath animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}
#pragma mark ------------------------------------ private
- (void)p_initUI {
    self.groupArray = [NSMutableArray new];

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor blackColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    UIButton *rightBtn = [UIButton new];
    [rightBtn sizeToFit];
    [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = kSystemFont(16);
    [rightBtn setTitleColor:kMAINCOLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(p_dismissGroupController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.tableView registerClass:[CTGroupTableViewCell class] forCellReuseIdentifier:NSStringFromClass([CTGroupTableViewCell class])];
    
}
// 首次进入 只获取一个照片类-全部照片
- (void)p_fetchAllPhotos {
    
    [CTPhotoManager fetchAllPhotosGroup:^(NSArray<PHAssetCollection *> * _Nonnull groupArray) {
        for (PHAssetCollection *col in groupArray) {
            CTGroupModel *model = [[CTGroupModel alloc] initWithPHAssetCollection:col];
            [self.groupArray addObject:model];
        }
        [self.tableView reloadData];
        if (self.isFirstLoad) {
            [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
        }
        [self p_showPhotosCollection:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO];
    }];
  
}
//进入照片类列表时 才加载全部列表
- (void)p_fetchAllGroup {
    if (!_needLoadAll) {
        [self.groupArray removeAllObjects];
        [CTPhotoManager fetchDefaultAllPhotosGroup:^(NSArray<PHAssetCollection *> * _Nonnull groupArray) {
            for (PHAssetCollection *col in groupArray) {
                CTGroupModel *model = [[CTGroupModel alloc] initWithPHAssetCollection:col];
                [self.groupArray addObject:model];
            }
            [self p_assortGroup];
            [self.tableView reloadData];
            self.needLoadAll = YES;
        }];
    }
}
//排序
- (void)p_assortGroup {
    NSInteger num = self.groupArray.count;
    for(int i = 0; i < num-1; i++) {
        
        int j = i+1;
        //排序 数量最多的放前面
        while (j<num) {
            NSUInteger count1 = self.groupArray[i].totalNum;
            NSUInteger count2 = self.groupArray[j].totalNum;
            if (count1<count2) {
                CTGroupModel *model = self.groupArray[i];
                self.groupArray[i] = self.groupArray[j];
                self.groupArray[j] = model;
            }
            j++;
        }
    }
}
- (void)p_showPhotosCollection:(NSIndexPath *)indexPath animated:(BOOL)animated {
    
    CTGroupModel *col = self.groupArray[indexPath.row];
    CTPhotosCollectionViewController *photos = [CTPhotosCollectionViewController new];
    photos.collection = col.collection;
    photos.photoBlock = self.photoBlock;
    [self.navigationController pushViewController:photos animated:animated];
}
- (void)p_dismissGroupController {

    [self dismissViewControllerAnimated:true completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

}
#pragma mark ------------------------------------ PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self p_fetchAllPhotos];
    });
}

- (void)dealloc {
    NSLog(@"%@ dealloc",self);
}
@end
