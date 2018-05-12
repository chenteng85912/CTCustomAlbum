//
//  AlbumViewController.h
//
//  Created by 腾 on 15/9/15.
//
//

#import <UIKit/UIKit.h>
#import "CTPhotosConfig.h"

@interface CTAlbumGroupController : UITableViewController

/**
 选择图片 回调
 */
@property (nonatomic, copy) CTCustomImagesBLock photoBlock;

@end
