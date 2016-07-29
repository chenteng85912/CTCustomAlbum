//
//  BigCollectionViewController.h
//  TYKYTwoLearnOneDo
//
//  Created by Apple on 16/7/22.
//  Copyright © 2016年 深圳太极云软技术股份有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BigCollectionViewControllerDelegate <NSObject>

- (void)sendImageFromBig:(NSMutableDictionary *)picDic;

@end

@interface BigCollectionViewController : UIViewController

@property (strong,nonatomic) NSArray *dataArray;//图片数据
@property (strong,nonatomic) NSMutableDictionary *selectDic;//选中图片
@property (assign,nonatomic) NSInteger index;//第一次显示的图片页码
@property (assign,nonatomic) NSInteger totalNum;//总图片数量

@property (nonatomic,weak) id <BigCollectionViewControllerDelegate> delegate;

@end
