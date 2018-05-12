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

@interface CTAlbumGroupController ()<PHPhotoLibraryChangeObserver>

@property (nonatomic, copy) NSArray <PHAssetCollection *> *groupArray;//相册列表数组

@end

@implementation CTAlbumGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"照片";

    [self.tableView registerClass:[CTGroupTableViewCell class] forCellReuseIdentifier:NSStringFromClass([CTGroupTableViewCell class])];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(p_dismissGroupController)];
    
    //注册实施监听相册变化
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];

    if ([CTSavePhotos checkAuthorityOfAblum]) {
        [self fetchGroupDatas];
    }

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

// 获取相册数组
- (void)fetchGroupDatas {
    
    __weak typeof(self) weakSelf = self;
    [CTPhotoManager fetchDefaultAllPhotosGroup:^(NSArray<PHAssetCollection *> * _Nonnull groupArray) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.groupArray = groupArray;
        [strongSelf.tableView reloadData];
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:strongSelf];

        [strongSelf p_showPhotosCollection:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
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
- (void)p_showPhotosCollection:(NSIndexPath *)indexPath animated:(BOOL)animated {
    
    PHAssetCollection *col = self.groupArray[indexPath.row];
    CTPhotosCollectionViewController *photos = [CTPhotosCollectionViewController new];
    photos.collection = col;
    photos.photoBlock = self.photoBlock;
    [self.navigationController pushViewController:photos animated:animated];
}
- (void)p_dismissGroupController {

    [self dismissViewControllerAnimated:true completion:nil];
}
#pragma mark ------------------------------------ PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    dispatch_sync(dispatch_get_main_queue(), ^{

        [self fetchGroupDatas];

    });
}
- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}
@end
