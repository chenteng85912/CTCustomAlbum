//
//  CTGroupTableViewCell.h
//
//  Created by chenteng on 2017/12/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface CTGroupTableViewCell : UITableViewCell

- (void)processCellData:(PHAssetCollection *)collection;

@end
