//
//  AlbumViewController.h
//  eyerecolor
//
//  Created by 腾 on 15/9/15.
//
//

#import <UIKit/UIKit.h>

@class ALAssetsGroup;
@protocol AlbumViewControllerDelegate <NSObject>

//切换相册类别
- (void)initGroupDetailsData:(ALAssetsGroup *)group;

@end
@interface AlbumViewController : UIViewController

@property (nonatomic,strong) NSMutableArray *groupArray;//相册分类
@property (nonatomic,weak) id <AlbumViewControllerDelegate>delegate;
@property (strong, nonatomic) UITableView *TbView;
@end
