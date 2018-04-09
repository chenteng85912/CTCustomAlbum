//
//  GroupAlbumViewController.h
//
//  Created by 腾 on 15/9/15.
//
//

#import "CTPhotosConfig.h"

@interface CTPhotosCollectionViewController : UIViewController

@property (nonatomic,strong) PHAssetCollection *collection;

@property (nonatomic, copy) CTCustomImagesBLock photoBlock;

@end
