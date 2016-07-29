//
//  GroupAlbumViewController.m
//  eyerecolor
//
//  Created by 腾 on 15/9/15.
//
//

#import "GroupAlbumViewController.h"
#import "AlbumCollectionViewCell.h"
#import "AlbumViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BigCollectionViewController.h"

#define Device_height   [[UIScreen mainScreen] bounds].size.height
#define Device_width    [[UIScreen mainScreen] bounds].size.width

@interface GroupAlbumViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,AlbumViewControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,BigCollectionViewControllerDelegate>

@property (strong, nonatomic)  UICollectionView *ColView;
@property (strong, nonatomic)  UIView *backView;

@property (nonatomic,strong) NSMutableArray *albumArray;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIImageView *titleLImg;
@property (nonatomic,strong) UIButton *titleBtn;
@property (nonatomic,strong) AlbumViewController *albumGroup;
@property (nonatomic,strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic,assign) BOOL isLoad;
@property (nonatomic,assign) NSInteger selectedNum;
@property (nonatomic,strong) UIView *waringView;
@end

@implementation GroupAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    NSString *rightTitle = [NSString stringWithFormat:@"确认(%ld/%ld)",(long)self.picDataDic.count,(long)self.totalNum];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:rightTitle style:UIBarButtonItemStylePlain target:self action:@selector(comfirnChoose)];
    
    [self changeComfirnTitie];
    if (!self.picDataDic) {
        self.picDataDic = [NSMutableDictionary new];

    }
    self.ColView.backgroundColor= [UIColor groupTableViewBackgroundColor];
    self.ColView.alwaysBounceVertical = YES;
    [self.ColView registerNib:[UINib nibWithNibName:@"AlbumCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"AlbumCollectionViewCell"];
    
    self.albumArray = [NSMutableArray new];
    
    [self initCollectionView];
    [self initAlbumGroupData];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [self.ColView reloadData];
    [self changeComfirnTitie];

}
- (NSMutableDictionary *)picDataDic{
    if (!_picDataDic) {
        _picDataDic = [NSMutableDictionary new];
        
    }
    return _picDataDic;
}
- (NSMutableArray *)albumArray{
    if (!_albumArray) {
        _albumArray = [NSMutableArray new];
    }
    return _albumArray;
}
#pragma mark collectionview
- (void)initCollectionView{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.sectionInset =  UIEdgeInsetsMake(1, 1, 1, 1);
    layout.minimumLineSpacing = 1.0;
    layout.minimumInteritemSpacing = 1.0;
    layout.itemSize = CGSizeMake((Device_width-4)/3, (Device_width-4)/3);
    
    UICollectionView *colView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, Device_width, Device_height-64) collectionViewLayout:layout];
    colView.delegate = self;
    colView.dataSource = self;
    [self.view addSubview:colView];
    colView.backgroundColor= [UIColor whiteColor];
    colView.alwaysBounceVertical = YES;
    [colView registerNib:[UINib nibWithNibName:@"AlbumCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"AlbumCollectionViewCell"];
    self.ColView = colView;
    
    UIView *backview = [[UIView alloc] initWithFrame:colView.frame];
    backview.backgroundColor = [UIColor blackColor];
    backview.alpha = 0;
    [self.view addSubview:backview];
    self.backView = backview;
    
    UIView *warning = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 90)];
    warning.center = self.view.center;
    warning.alpha = 0.0;
    warning.backgroundColor = [UIColor blackColor];
    warning.layer.masksToBounds = YES;
    warning.layer.cornerRadius = 5.0;
    
    UIImageView *warningImg = [[UIImageView alloc] initWithFrame:CGRectMake(warning.frame.size.width/2-15, 15, 30, 30)];
    warningImg.image = [UIImage imageNamed:@"max_warinig"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, warning.frame.size.width, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor  = [UIColor whiteColor];
    label.text = @"照片数量已到上限";
    
    [warning addSubview:warningImg];
    [warning addSubview:label];
    
    [self.navigationController.view addSubview:warning];
    [self.navigationController.view bringSubviewToFront:warning];
    self.waringView = warning;
    
}
- (void)initTitleView:(ALAssetsGroup *)group{
    
    UILabel *label = [self fixLabelWithGroup:group andFontSize:16];
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(label.frame.size.width+5, 0, 20, 20)];
    img.image = [UIImage imageNamed:@"down_album"];
    self.titleLImg = img;
    
    UIView *customTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, label.frame.size.width+35, 20)];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, label.frame.size.width+35, 20)];
    self.titleBtn = btn;
    [btn addTarget:self action:@selector(choosePhotosGroup:) forControlEvents:UIControlEventTouchUpInside];
    
    [customTitle addSubview:label];
    [customTitle addSubview:img];
    [customTitle addSubview:btn];
    self.navigationItem.titleView = customTitle;
    
}

- (void)initAlbumGroupData{
    
    NSMutableArray *groupArray = [NSMutableArray new];
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];

    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            if(group.numberOfAssets>0){
                [groupArray addObject:group];

            }
        }else{
            
            AlbumViewController *tbView = [AlbumViewController new];
            tbView.delegate = self;
            self.albumGroup = tbView;
            tbView.view.frame = CGRectMake(0,  -Device_height/2, Device_width, Device_height/2);
            tbView.TbView.frame = CGRectMake(0, 0, Device_width, Device_height/2);

            tbView.groupArray = [groupArray mutableCopy];
            [tbView.TbView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            
            [self.view addSubview:tbView.view];
            [self.view bringSubviewToFront:tbView.view];
            [self addChildViewController:tbView];
            
            ALAssetsGroup *group = groupArray[groupArray.count-1];

            [self initGroupDetailsData:group];
            [self initTitleView:group];

        }
        
    } failureBlock:^(NSError *error) {
        NSLog(@"Group not found!\n");
    }];

}

- (void)initGroupDetailsData:(ALAssetsGroup *)group{
    

    [self.albumArray removeAllObjects];
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result){
            [self.albumArray insertObject:result atIndex:0];
          

        }else{
            
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (self.isLoad) {
                     [self choosePhotosGroup:self.titleBtn];
                     [self initTitleView:group];

                 }
                 self.isLoad = YES;

                 [self.ColView reloadData];
             });
            
        }
    }];

}

#pragma  mark 展示照片分组
- (void)choosePhotosGroup:(UIButton *)btn{
    
    [UIView animateWithDuration:0.25 animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        if (!btn.selected) {
            self.titleLImg.image = [UIImage imageNamed:@"up_album"];

            self.albumGroup.view.center = CGPointMake(Device_width/2, Device_height/4);
            self.backView.alpha = 0.5;
            btn.selected = YES;
        }else{
            self.titleLImg.image = [UIImage imageNamed:@"down_album"];

            self.albumGroup.view.center = CGPointMake(Device_width/2, -Device_height/4);
            btn.selected = NO;
             self.backView.alpha = 0;
        }
    }];
}

#pragma mark 图片确认选择
- (void)comfirnChoose{
    
    if ([self.delegate respondsToSelector:@selector(sendImageDictionary:)]) {
        
        [self.delegate sendImageDictionary:self.picDataDic];
        [self back];
        
    }
    
}

- (void)sendImageFromBig:(NSMutableDictionary *)picDic{
    if ([self.delegate respondsToSelector:@selector(sendImageDictionary:)]) {
        
        [self.delegate sendImageDictionary:picDic];
        [self back];
        
    }
}
- (void)back{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UICollectionViewDelegate
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.albumArray.count+1;
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumCollectionViewCell *mycell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlbumCollectionViewCell" forIndexPath:indexPath];
    
    if (indexPath.row==0) {
        mycell.selectBut.hidden = YES;
        mycell.imgView.image = nil;
        mycell.cameraView.hidden = NO;
        mycell.backView.hidden = YES;

    }else{
        mycell.cameraView.hidden = YES;
        ALAsset *asset = self.albumArray[indexPath.row-1];
        if ([self.picDataDic.allKeys containsObject:asset.defaultRepresentation.filename]) {
            mycell.selectBut.selected = YES;
            mycell.backView.hidden = NO;

            
        }else{
            mycell.selectBut.selected = NO;
            mycell.backView.hidden = YES;

        }
        mycell.selectBut.hidden = NO;
        mycell.imgView.image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
        
        mycell.selectBut.tag = indexPath.row;
        [mycell.selectBut addTarget:self action:@selector(choosePicture:) forControlEvents:UIControlEventTouchUpInside];
    }
    return mycell;
}

#pragma mark - UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row==0) {
        if (self.totalNum==self.picDataDic.count) {
            [self showWaringView];
            return;
        }
        [self openCamera];
        return;
    }
    
    //BigPhotoViewController *big = [BigPhotoViewController new];
    BigCollectionViewController *big = [BigCollectionViewController new];

    big.delegate = self;
    big.dataArray = self.albumArray;
    big.index = indexPath.row;
    big.totalNum = self.totalNum;
    big.selectDic = self.picDataDic;

    [self.navigationController pushViewController:big animated:YES];
    
}
#pragma mark 选择照片
- (void)choosePicture:(UIButton *)btn{
    ALAsset *asset = self.albumArray[btn.tag-1];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:btn.tag inSection:0];

    if ([self.picDataDic.allKeys containsObject:asset.defaultRepresentation.filename]) {
        [self.picDataDic removeObjectForKey:asset.defaultRepresentation.filename];
        AlbumCollectionViewCell *mycell = (AlbumCollectionViewCell *)[self.ColView cellForItemAtIndexPath:indexPath];
        mycell.selectBut.selected = NO;
        mycell.backView.hidden = YES;
        [self changeComfirnTitie];
        
    }else{
        if (self.totalNum==self.picDataDic.count) {
            [self showWaringView];
            return;
        }
        [self.picDataDic setObject:[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage] forKey:asset.defaultRepresentation.filename];
        AlbumCollectionViewCell *mycell = (AlbumCollectionViewCell *)[self.ColView cellForItemAtIndexPath:indexPath];
        [self showAnimation:mycell.selectBut];
        mycell.backView.hidden = NO;

        [self changeComfirnTitie];
    }

}
#pragma mark 照片选中按钮动画
- (void)showAnimation:(UIButton *)but{
    but.selected = YES;
    [UIView animateWithDuration:0.1
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         but.transform = CGAffineTransformMakeScale(0.9,0.9);
                         
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.1
                                               delay:0
                                             options: UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              but.transform = CGAffineTransformMakeScale(1.1,1.1);
                                              
                                          }
                                          completion:^(BOOL finished){
                                              [UIView animateWithDuration:0.1
                                                                    delay:0
                                                                  options: UIViewAnimationOptionCurveEaseIn
                                                               animations:^{
                                                                   but.transform = CGAffineTransformMakeScale(1.0,1.0);
                                                                   
                                                               }
                                                               completion:^(BOOL finished){
                                                                   
                                                               }];
                                          }];
                     }];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

//    if (Device_width>=375) {
//        return CGSizeMake((Device_width-5)/4, (Device_width-5)/4);
//    }
    
    return  CGSizeMake((Device_width-4)/3, (Device_width-4)/3);

}

#pragma mark 改变确认按钮状态
- (void)changeComfirnTitie{
    
    if (self.picDataDic.count==0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"确认(%ld/%ld)",(long)self.picDataDic.count,(long)self.totalNum];

}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y<-100) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark 打开摄像头
- (void)openCamera{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //相机不可用
        return;
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.sourceType=UIImagePickerControllerSourceTypeCamera;
    //picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *newImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(newImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);

    [picker dismissViewControllerAnimated:YES completion:^{
        [self.picDataDic setObject:newImage forKey:[NSString stringWithFormat:@"%.f.JPG",[[NSDate new] timeIntervalSince1970]]];
        [self comfirnChoose];
       
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    NSLog(@"saved..");
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];

    if (self.titleBtn.selected) {
        [self choosePhotosGroup:self.titleBtn];

    }


}

- (UILabel *)fixLabelWithGroup:(ALAssetsGroup *)group andFontSize:(CGFloat)fontSize{
    
    
    UILabel *label = [UILabel new];
    label.textColor = [UIColor whiteColor];
    label.text = [group  valueForProperty:ALAssetsGroupPropertyName];
    label.font = [UIFont systemFontOfSize:fontSize];
    CGSize maxSize = [label.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size;
    label.frame = CGRectMake(0, 0, maxSize.width, maxSize.height);

    return label;
}

- (void)showWaringView{
    [UIView animateWithDuration:0.2
                          delay:0.
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.waringView.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5
                                               delay:0.5
                                             options: UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              self.waringView.alpha = 0.0;
                                          }
                                          completion:^(BOOL finished){
                                              
                                          }];
                     }];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
