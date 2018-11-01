//
//  GroupAlbumViewController.h
//
//  Created by 腾 on 15/9/15.
//
//

#import "CTPhotosConfig.h"

@interface CTPhotosCollectionViewController : UIViewController

/**
 系统相册分类
 */
@property (nonatomic, strong) PHAssetCollection *collection;

/**
 图片 视频 发送时触发回调
 */
@property (nonatomic, copy) CTCustomMediasBLock photoBlock;

@end
