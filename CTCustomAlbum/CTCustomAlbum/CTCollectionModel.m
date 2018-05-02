//
//  CTCollectionModel.m
//
//  Created by chenteng on 2017/12/17.
//  Copyright © 2017年 CHENTENG. All rights reserved.
//

#import "CTCollectionModel.h"
#import "CTPhotosConfig.h"

float const kCTPhotoStandard = 1024.0;

@implementation CTCollectionModel

- (void)addSelectedIndex:(NSInteger)index{
    CTPHAssetModel *model = self.albumArray[index];
    if (![self.selectedArray containsObject:model]) {
        [self.selectedArray addObject:model];
    }
}
- (void)removeSelectedIndex:(NSInteger)index{
    CTPHAssetModel *model = self.albumArray[index];
    if ([self.selectedArray containsObject:model]) {
        [self.selectedArray removeObject:model];
    }
}
- (NSString *)sendBtnTitle{
  
    if (self.selectedArray.count==0) {
        return @"发送";
    }else{
        return [NSString stringWithFormat:@"发送(%lu)",(unsigned long)self.selectedArray.count];
    }
    
}

- (NSString *)calucateImagesSize{
    NSInteger totalSize = 0;
    for (CTPHAssetModel *model in self.selectedArray) {
        totalSize += [model.asset getImageSize].unsignedIntegerValue;
    }
    if (totalSize) {
        return photoSizeWithLength(totalSize);
    }
    return nil;
}
- (NSMutableArray <CTPHAssetModel *> *)albumArray{
    if (!_albumArray) {
        _albumArray = [NSMutableArray new];
    }
    return _albumArray;
}
- (NSMutableArray <CTPHAssetModel *> *)selectedArray{
    if (!_selectedArray) {
        _selectedArray = [NSMutableArray new];
    }
    return _selectedArray;
}
static inline NSString * photoSizeWithLength(NSUInteger length){
    
    //如果达到MB
    if (length > kCTPhotoStandard * kCTPhotoStandard)
    {
        return [NSString stringWithFormat:@"%.1fMB",length / kCTPhotoStandard / kCTPhotoStandard];
    }
    
    
    else if (length > kCTPhotoStandard)
    {
        return [NSString stringWithFormat:@"%.0fKB",length / kCTPhotoStandard];
    }
    
    else
    {
        return [NSString stringWithFormat:@"%@B",@(length)];
    }
    
    return @"";
}
@end
