//
//  CTCollectionModel.m
//
//  Created by chenteng on 2017/12/17.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import "CTCollectionModel.h"
#import "CTPhotosConfig.h"

static float const kCTPhotoStandard = 1024.0;

@implementation CTCollectionModel

- (void)refreshSelectedDataNumber {
    for (int i =0; i<self.selectedArray.count; i++) {
        CTPHAssetModel *model = self.selectedArray[i];
        model.chooseNum = [NSString stringWithFormat:@"%d",i+1];
    }
}
#pragma mark ------------------------------------ get
- (NSString *)sendBtnTitle{
  
    if (self.selectedArray.count==0) {
        return @"确定";
    }else{
        return [NSString stringWithFormat:@"确定(%lu)",(unsigned long)self.selectedArray.count];
    }
    
}

- (NSString *)calucateImagesSize {
    NSInteger totalSize = 0;
    for (CTPHAssetModel *model in self.selectedArray) {
        totalSize += [model.asset getImageSize].unsignedIntegerValue;
    }
    if (totalSize) {
        return photoSizeWithLength(totalSize);
    }
    return nil;
}

static inline NSString * photoSizeWithLength(NSUInteger length) {
    
    //如果达到MB
    if (length > kCTPhotoStandard * kCTPhotoStandard) {
        return [NSString stringWithFormat:@"%.1fMB",length / kCTPhotoStandard / kCTPhotoStandard];
    }
    
    
    else if (length > kCTPhotoStandard) {
        return [NSString stringWithFormat:@"%.0fKB",length / kCTPhotoStandard];
    }
    
    else {
        return [NSString stringWithFormat:@"%@B",@(length)];
    }
    
    return @"";
}
#pragma mark ------------------------------------ lazy
- (NSMutableArray <CTPHAssetModel *> *)albumArray {
    if (!_albumArray) {
        _albumArray = [NSMutableArray new];
    }
    return _albumArray;
}
- (NSMutableArray <CTPHAssetModel *> *)selectedArray {
    if (!_selectedArray) {
        _selectedArray = [NSMutableArray new];
    }
    return _selectedArray;
}

@end
