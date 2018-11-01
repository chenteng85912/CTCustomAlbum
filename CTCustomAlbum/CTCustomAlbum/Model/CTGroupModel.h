//
//  CTGroupModel.h
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/7/21.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "PHAssetCollection+CTAssetCollectionManager.h"

@interface CTGroupModel : NSObject

@property (nonatomic, readonly) PHAssetCollection *collection;
@property (nonatomic, readonly) UIImage *iconImg;
@property (nonatomic, readonly) NSAttributedString *attrGroupName;
@property (nonatomic, readonly) NSString *groupName;
@property (nonatomic, readonly) NSInteger totalNum;
@property (nonatomic, readonly) BOOL isVideo;

- (instancetype)initWithPHAssetCollection:(PHAssetCollection *)collection;

@end
