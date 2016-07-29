//
//  ViewController.m
//  Custom_Album_Demo
//
//  Created by 腾 on 16/7/29.
//  Copyright © 2016年 腾. All rights reserved.
//

#import "ViewController.h"
#import "CTPictureShowViewController.h"
#import "GroupAlbumViewController.h"
#import "ONEPhoto.h"

#define Device_height   [[UIScreen mainScreen] bounds].size.height
#define Device_width    [[UIScreen mainScreen] bounds].size.width
@interface ViewController ()<ONEPhotoDelegate,GroupAlbumViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *oneImage;
@property (strong, nonatomic) CTPictureShowViewController *pictureShow;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)selectPhotoAction:(UIButton *)sender {
    if (sender.tag==0) {
        [ONEPhoto shareSigtonPhoto].delegate =self;
        [[ONEPhoto shareSigtonPhoto] openAlbum:self editModal:NO];//打开相册选择单张照片
        //[[ONEPhoto shareSigtonPhoto] openCamera:self editModal:NO];//打开摄像头拍摄单张照片

    }else{
        GroupAlbumViewController *album = [GroupAlbumViewController new];
        album.delegate = self;
        album.totalNum = 12;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:album];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)sendImageDictionary:(NSDictionary *)imageDic{
    self.oneImage.image = nil;
    if (!self.pictureShow) {
        CTPictureShowViewController *show = [CTPictureShowViewController new];
        show.view.frame = CGRectMake(0, 100, Device_width, Device_height-150);
        [self addChildViewController:show];
        [self.view addSubview:show.view];
        
        self.pictureShow = show;
    }
    self.pictureShow.dataDic = [imageDic mutableCopy];

    [self.pictureShow.colView reloadData];
    
}
- (void)sendOnePhoto:(UIImage *)image{
    [self.pictureShow.view removeFromSuperview];
    [self.pictureShow removeFromParentViewController];
    self.pictureShow = nil;

    self.oneImage.image = image;
    self.oneImage.frame = [self makeImageView:image];
    self.oneImage.center = CGPointMake(Device_width/2, Device_height/2);
}
- (CGRect )makeImageView:(UIImage *)image{
    
    CGSize imageSize = image.size;
    CGFloat scaleW = imageSize.width/Device_width;
    CGFloat picHeight = imageSize.height/scaleW;
    
    CGFloat picW;
    CGFloat picH;
    
    if (picHeight>Device_height) {
        CGFloat scaleH = picHeight/(Device_height);
        picW = Device_width/scaleH;
        picH = Device_height;
    }else{
        picW = Device_width;
        picH = picHeight;
    }

    return CGRectMake(0, 0, picW, picH);
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
