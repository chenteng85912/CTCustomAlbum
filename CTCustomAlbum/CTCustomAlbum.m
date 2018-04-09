//
//  CTCustomAlbum.m
//  TYKYLibraryDemo
//
//  Created by 陈腾 on 2018/4/4.
//  Copyright © 2018年 CHENTENG. All rights reserved.
//

#import "CTCustomAlbum.h"
#import "CTPhotosNavigationViewController.h"

@implementation CTCustomAlbum

+ (void)showCustomAlbumWithDelegate:(id <CTSendPhotosProtocol>)delegate{
    CTPhotosNavigationViewController *nav = [CTPhotosNavigationViewController initWithDelegate:delegate];
    
    [[self p_currentViewController] presentViewController:nav animated:YES completion:nil];
}
+ (void)showCustomAlbumWithDelegate:(id <CTSendPhotosProtocol>)delegate
                         photoScale:(CGFloat)scale
                             maxNum:(NSInteger)maxNum{
    CTPhotosNavigationViewController *nav = [CTPhotosNavigationViewController initWithDelegate:delegate
                                                                                    photoScale:scale
                                                                                        maxNum:maxNum];
    
    [[self p_currentViewController] presentViewController:nav animated:YES completion:nil];
}
+ (void)showCustomAlbumWithBlock:(CTCustomImagesBLock)block{
    CTPhotosNavigationViewController *nav = [CTPhotosNavigationViewController initWithBlock:block];
    [[self p_currentViewController] presentViewController:nav animated:YES completion:nil];

}
+ (void)showCustomAlbumWithBlock:(CTCustomImagesBLock)block
                      photoScale:(CGFloat)scale
                          maxNum:(NSInteger)maxNum{
    CTPhotosNavigationViewController *nav = [CTPhotosNavigationViewController initWithBlock:block
                                                                                 photoScale:scale
                                                                                     maxNum:maxNum];
    [[self p_currentViewController] presentViewController:nav animated:YES completion:nil];
}

//获取最顶部控制器
+ (UIViewController *)p_currentViewController {
    
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1)
    {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController *)vc).selectedViewController;
        }else if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController *)vc).visibleViewController;
        }else if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}
@end
