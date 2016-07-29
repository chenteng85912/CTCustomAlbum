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

- (void)initGroupDetailsData:(ALAssetsGroup *)group;

@end
@interface AlbumViewController : UIViewController

@property (nonatomic,strong) NSMutableArray *groupArray;
@property (nonatomic,weak) id <AlbumViewControllerDelegate>delegate;
@property (strong, nonatomic) UITableView *TbView;
@end
