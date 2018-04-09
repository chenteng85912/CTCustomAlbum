//
//  CTCollectionModel.h
//
//  Created by chenteng on 2017/12/17.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTPHAssetModel.h"

@interface CTCollectionModel : NSObject

//相册数组
@property (nonatomic,strong) NSMutableArray <CTPHAssetModel *> *albumArray;

//选中相册数组
@property (nonatomic,strong) NSMutableArray <CTPHAssetModel *> *selectedArray;

//是否输出原图
@property (nonatomic,assign) BOOL sendOriginImg;

//发送按钮标题
@property (nonatomic,copy,readonly) NSString *sendBtnTitle;

//点击的图片位置
@property (nonatomic,assign) NSInteger currenIndex;

//选中
- (void)addSelectedIndex:(NSInteger)index;

//移除
- (void)removeSelectedIndex:(NSInteger)index;

//计算选中的图片大小总数
- (NSString *)calucateImagesSize;

@end
