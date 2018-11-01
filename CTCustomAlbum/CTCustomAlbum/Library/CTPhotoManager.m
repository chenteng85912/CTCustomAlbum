//
//  PhotosDataCenter.m
//
//  Created by chenteng on 2017/12/4.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "CTPhotoManager.h"

@implementation CTPhotoManager

static id<CTSendPhotosProtocol>CTDelegate = nil;

+ (void)setDelegate:(id<CTSendPhotosProtocol>)delegate {
    CTDelegate = delegate;
}
+ (id <CTSendPhotosProtocol>)delegate {
    return CTDelegate;
}
+ (void)fetchAllPhotosGroup:(void (^)(NSArray<PHAssetCollection *> * groupArray))groupsBlock {
    //获得全部照片
    PHFetchResult * smartGroups = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    if (groupsBlock) {
        if (smartGroups.count>0) {
            groupsBlock(@[smartGroups[0]]);

        }else {
            groupsBlock(@[]);
        }
    }
//    [smartGroups enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (obj.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
//            if (groupsBlock) {
//                groupsBlock(@[obj]);
//                *stop = YES;
//            }
//        }
//    }];
    
}
+ (void)fetchDefaultAllPhotosGroup:(void (^)(NSArray<PHAssetCollection *> * groupArray))groupsBlock {
    
    [self p_fetchDefaultPhotosGroup:^(NSArray<PHAssetCollection *> * _Nonnull defaultGroups) {
        
        if ([NSThread isMainThread]) {
            groupsBlock(defaultGroups);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
         groupsBlock(defaultGroups);
        });
    }];
    
}

+ (void)p_fetchDefaultPhotosGroup:(void (^)(NSArray<PHAssetCollection *> * _Nonnull))groups {
    __block NSMutableArray <PHAssetCollection *> * defaultAllGroups = [NSMutableArray arrayWithCapacity:0];

    [self p_fetchBasePhotosGroup:^(NSArray<PHAssetCollection *> * _Nullable result) {
        
        [defaultAllGroups addObjectsFromArray:result];
        
        //遍历自定义的组
        PHFetchResult *userResult = [PHCollection fetchTopLevelUserCollectionsWithOptions:[PHFetchOptions new]];
        for (PHAssetCollection *asset in userResult) {
            if ([asset isKindOfClass:[PHAssetCollection class]]) {
                [defaultAllGroups addObject:asset];
            }
        }
        groups([defaultAllGroups copy]);
        
    }];
}
/** 获取最基本的智能分组 */
+ (void)p_fetchBasePhotosGroup:(void(^)(NSArray<PHAssetCollection *> * _Nullable  result))completeBlock {

    //获得智能分组
    PHFetchResult * smartGroups = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    [self p_filterGroup:smartGroups complete:^(NSArray<PHAssetCollection *>  * _Nonnull results) {
        completeBlock(results);
    }];
    
}
// 将configuration属性中的类别进行筛选
+ (void)p_filterGroup:(PHFetchResult<PHAssetCollection *> *)fetchResult
           complete:(void (^)(NSArray<PHAssetCollection *>  * _Nonnull results))groups {
    __block  NSMutableArray <PHAssetCollection *> * preparationCollections = [NSMutableArray arrayWithCapacity:0];
    
    [fetchResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([CTPhotosConfiguration.groupNamesConfig containsObject:@(obj.assetCollectionSubtype)]) {
            [preparationCollections addObject:obj];
        }
        
        if (idx == fetchResult.count - 1) {
            groups([preparationCollections copy]);
            preparationCollections  = nil;
        }
    }];
    
}

//发送图片 视频
+ (void)sendImageData:(CTCollectionModel *)collectionModel
          imagesBlock:(CTCustomMediasBLock)imagesBlock {
    
    CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{

        for (CTPHAssetModel *model in collectionModel.selectedArray) {
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            [model creatResultData:collectionModel.sendOriginImg complete:^{
                dispatch_semaphore_signal(sema);
            }];
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
    });

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
        NSLog(@"Linked in %.2f s", linkTime);
        if (imagesBlock) {
            imagesBlock([collectionModel.selectedArray copy]);
        }
    });
}

@end
