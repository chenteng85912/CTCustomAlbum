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

@property (strong,nonatomic) NSArray *dataArray;
@property (strong,nonatomic) NSMutableDictionary *selectDic;
@property (assign,nonatomic) NSInteger index;
@property (assign,nonatomic) NSInteger totalNum;
@property (nonatomic,weak) id <BigCollectionViewControllerDelegate> delegate;

@end
