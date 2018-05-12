//
//  CTCollectionModel.h
//
//  Created by chenteng on 2017/12/17.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTPHAssetModel.h"

@interface CTCollectionModel : NSObject

/**
 某个分类的所有图片
 */
@property (nonatomic, strong) NSMutableArray <CTPHAssetModel *> *albumArray;

/**
 选中图片数组
 */
@property (nonatomic ,strong) NSMutableArray <CTPHAssetModel *> *selectedArray;

/**
 是否输出原图
 */
@property (nonatomic, assign) BOOL sendOriginImg;

/**
 发送按钮标题
 */
@property (nonatomic, copy, readonly) NSString *sendBtnTitle;

/**
 预览大图时初始位置
 */
@property (nonatomic, assign) NSInteger currenIndex;

/**
 选中图片

 @param index 图片序号
 */
- (void)addSelectedIndex:(NSInteger)index;

/**
 移除图片

 @param index 图片序号
 */
- (void)removeSelectedIndex:(NSInteger)index;

/**
 计算选中所有图片大小总数

 @return 图片大小 （带单位）
 */
- (NSString *)calucateImagesSize;

@end
