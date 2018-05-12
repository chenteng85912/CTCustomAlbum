//
//  CTGroupTableViewCell.h
//
//  Created by chenteng on 2017/12/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface CTGroupTableViewCell : UITableViewCell

/**
绘制单元格

 @param collection 图片数据
 */
- (void)processCellData:(PHAssetCollection *)collection;

@end
