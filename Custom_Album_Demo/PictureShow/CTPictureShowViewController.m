//
//  TJFeedbackImageViewController.m
//  zhumadianparent
//
//  Created by Apple on 16/6/7.
//  Copyright © 2016年 深圳太极云软技术股份有限公司. All rights reserved.
//

#import "CTPictureShowViewController.h"
#import "CTPictureShowCollecionCell.h"

#define Device_height   [[UIScreen mainScreen] bounds].size.height
#define Device_width    [[UIScreen mainScreen] bounds].size.width

@interface CTPictureShowViewController ()

@end

@implementation CTPictureShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.colView registerNib:[UINib nibWithNibName:@"CTPictureShowCollecionCell" bundle:nil] forCellWithReuseIdentifier:@"CTPictureShowCollecionCell"];
    self.colView.alwaysBounceVertical = YES;
}

- (NSMutableDictionary *)dataDic{
    if (!_dataDic) {
        _dataDic = [NSMutableDictionary new];
    }
    return _dataDic;
}

//删除图片 动画
- (void)deleteCell:(UIButton *)but{
    

    [self.colView performBatchUpdates:^{
        NSString *imgName = self.dataDic.allKeys[but.tag];
        [self.dataDic removeObjectForKey:imgName];

        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:but.tag inSection:0];
        
        [self.colView deleteItemsAtIndexPaths:@[indexpath]];
    } completion:^(BOOL finished) {
        [self.colView reloadData];

    }];
    
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  
    return self.dataDic.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CTPictureShowCollecionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CTPictureShowCollecionCell" forIndexPath:indexPath];
    
    NSString *imgName = self.dataDic.allKeys[indexPath.row];

    cell.imgView.image = self.dataDic[imgName];
    
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake((Device_width-4)/3, (Device_width-4)/3);
    
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
