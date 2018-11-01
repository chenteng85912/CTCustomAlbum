//
//  CTPreviewImageView.m
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/9/25.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import "CTPreviewImageView.h"
#import "CTPHAssetModel.h"
#import "CTPhotosCollectionViewCell.h"

CGFloat const kPreviewImageHeight = 80.0;

@interface CTPreviewImageView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *colView;
@property (nonatomic, strong) NSMutableArray *dataArrm;
@property (nonatomic, strong) CTPHAssetModel *curruntModel;

@end

@implementation CTPreviewImageView

+ (instancetype)initWithFrame:(CGRect)frame
                   dataSource:(NSMutableArray *)dataArrm {
    return [[self alloc] initWithFrame:frame dataSource:dataArrm];
}

- (instancetype)initWithFrame:(CGRect)frame
                   dataSource:(NSMutableArray *)dataArrm {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [kColorValue(0x1A1A1A) colorWithAlphaComponent:0.8];
        _dataArrm = dataArrm;
    }
    return self;
}

- (void)refreshData:(CTPHAssetModel *)curruntModel {
    _curruntModel = curruntModel;
    [self.colView reloadData];
    if (_dataArrm.count==0) {
        return;
    }
    NSInteger index = 0;
    for (CTPHAssetModel *model in _dataArrm) {
        if (curruntModel.indexPath.row == model.indexPath.row) {
            index = [_dataArrm indexOfObject:model];
        }
    }
    [self.colView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}
#pragma mark ------------------------------------ UICollectionViewDelegate UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArrm.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CTPhotosCollectionViewCell *mycell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CTPhotosCollectionViewCell class]) forIndexPath:indexPath];
    return mycell;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CTPHAssetModel *model = self.dataArrm[indexPath.row];
    CTPhotosCollectionViewCell *mycell = (CTPhotosCollectionViewCell *)cell;
    [mycell processData:model indexPath:indexPath showFrame:YES];
    if (model.indexPath.row == _curruntModel.indexPath.row) {
        mycell.frameView.hidden = NO;
    }else {
        mycell.frameView.hidden = YES;
    }
   
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CTPHAssetModel *model = self.dataArrm[indexPath.row];
    if (model.indexPath.row == _curruntModel.indexPath.row) {
        return;
    }
    _curruntModel = model;
    [self.colView reloadData];
    if (_didCellBlock) {
        _didCellBlock(model);
    }
}
#pragma mark ------------------------------------ lazy
- (UICollectionView *)colView {
    if (!_colView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.sectionInset =  UIEdgeInsetsMake(0, 10, 0, 10);
        layout.minimumInteritemSpacing = 10.0;
        layout.itemSize = CGSizeMake(self.frame.size.height-20, self.frame.size.height-20);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _colView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _colView.delegate = self;
        _colView.dataSource = self;
        _colView.alwaysBounceHorizontal = YES;
        _colView.directionalLockEnabled = YES;
        _colView.backgroundColor= [UIColor clearColor];
        [_colView registerClass:[CTPhotosCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([CTPhotosCollectionViewCell class])];
        [self addSubview:_colView];
    }
    return _colView;
}
@end
