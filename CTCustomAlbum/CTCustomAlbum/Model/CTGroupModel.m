//
//  CTGroupModel.m
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/7/21.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import "CTGroupModel.h"

@interface CTGroupModel ()


@end

@implementation CTGroupModel

- (instancetype)initWithPHAssetCollection:(PHAssetCollection *)collection {
    if (self = [super init]) {
        _collection = collection;
        _isVideo = (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumVideos) ? YES : NO;
        [self p_fetchData];
    }
    return self;
}

- (void)p_fetchData {
    
    [_collection fetchCollectionInfoWithSize:CGSizeMake(60, 60) complete:^(NSString * _Nonnull title, NSUInteger assetCount, UIImage * _Nullable image) {
        self->_iconImg = image;
        self->_totalNum = assetCount;
        NSString *count = [NSString stringWithFormat:@"(%lu)",(unsigned long)assetCount];
        NSMutableAttributedString *countStr = [[NSMutableAttributedString alloc] initWithString:count attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        
        NSMutableAttributedString *titleAtt = [[NSMutableAttributedString alloc] initWithString:title];
        [titleAtt appendAttributedString:countStr];
        [titleAtt addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} range:NSMakeRange(0, titleAtt.length)];
        self->_attrGroupName = titleAtt;
        self->_groupName = title;
    }];
}
@end
