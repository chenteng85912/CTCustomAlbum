//
//  BigCollectionViewController.h
//
//  Created by Apple on 16/7/22.
//  Copyright © 2016年 深圳太极云软技术股份有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTPrviewImageScrollView.h"
#import "CTPhotosConfig.h"
#import "CTCollectionModel.h"
#import "UIViewController+CTAlertShow.h"
#import "CTBottomView.h"

@class CTPHAssetModel;

@interface CTPreviewPhotosCollectionViewController : UIViewController

/**
 相册分类模型
 */
@property (nonatomic, strong) CTCollectionModel *collectionModel;

/**
 图片选中 回调
 */
@property (nonatomic,   copy) CTCustomImagesBLock photoBlock;

/**
 点击图片的序号
 */
@property (nonatomic, assign) NSInteger currenIndex;

/**
 3D touch模式进入
 */
@property (nonatomic, assign) BOOL preview3D;

@end

