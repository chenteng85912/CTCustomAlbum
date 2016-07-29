//
//  GroupAlbumViewController.h
//  eyerecolor
//
//  Created by 腾 on 15/9/15.
//
//

#import <UIKit/UIKit.h>

@protocol GroupAlbumViewControllerDelegate <NSObject>

- (void)sendImageDictionary:(NSDictionary *)imageDic;

@end

@interface GroupAlbumViewController : UIViewController
@property (nonatomic,assign) NSInteger totalNum;//照片最大选择张数
@property (nonatomic,strong) NSMutableDictionary *picDataDic;
@property (nonatomic,weak) id <GroupAlbumViewControllerDelegate> delegate;

@end
