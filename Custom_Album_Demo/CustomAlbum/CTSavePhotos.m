//
//  SaveImageTool.m
//  webhall
//
//  Created by Apple on 2016/12/21.
//  Copyright © 2016年 深圳太极软件有限公司. All rights reserved.
//

#import "CTSavePhotos.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface CTSavePhotos ()
@property (strong, nonatomic) ALAssetsLibrary *library;

@end
@implementation CTSavePhotos

/** 懒加载 只创建一次library对象 */
- (ALAssetsLibrary *)library
{
    if (!_library) {
        _library = [[ALAssetsLibrary alloc] init];
    }
    
    return _library;
}

//获取项目名称 作为相册分类
- (NSString *)getGroupName{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    NSString *groupName = [infoDictionary objectForKey:@"CFBundleDisplayName"];

    return groupName;
}

//保存图片到相册 自定义分类名称
- (void)saveImageIntoAlbum:(UIImage *)image{
    
    __weak CTSavePhotos *weakSelf = self;
    
    //图片库
    __weak ALAssetsLibrary *weakLibrary = self.library;
    
    //创建自定义的相册
    [weakLibrary addAssetsGroupAlbumWithName:[self getGroupName] resultBlock:^(ALAssetsGroup *group) {

        if (group) {
            //新创建的文件夹
            //直接把图片添加到文件夹中
            [self addImageToGroup:group withImage:image];
        }else
        {
            //遍历相册中的每一个文件
            [weakLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                //取出文件夹的名称
                NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
                if ([name isEqualToString:[weakSelf getGroupName]]) { //如果相等,那么就是自己创建的文件夹
                    //添加图片到文件夹中
                    [self addImageToGroup:group withImage:image];
                    
                    *stop = YES; // 将图片添加到了文件夹中就停止遍历
                }else if ([name isEqualToString:@"Camera Roll"]){
                    
                    //创建新的文件夹中
                    [weakLibrary addAssetsGroupAlbumWithName:[weakSelf getGroupName] resultBlock:^(ALAssetsGroup *group) {
                        
                        //添加图片到文件夹中
                        [self addImageToGroup:group withImage:image];
                        
                        
                    } failureBlock:nil];
                }
            } failureBlock:nil];
        }
    } failureBlock:nil];
}

/** 添加一张图片到某个文件夹中 */
- (void)addImageToGroup:(ALAssetsGroup *)group withImage:(UIImage *)image
{
//    __weak ALAssetsLibrary *weakLibrary = self.library;
    
    //添加图片到相机胶卷 (因为要先存到全部的相片里面. 在根据对应的assetURL)
    [ self.library writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        // asset就是一张照片
        [self.library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            //将照片保存到自定的文件夹中
        
            [group addAsset:asset];
            
        } failureBlock:nil];
        
    }];
    
}

//检测相册权限
- (BOOL)checkAuthorityOfAblum{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
        //无权限

        [self showAlertWithMessage:@"相册被禁止访问了，请前往设置进行更改" ];

        return NO ;
    }
    return YES;
}
//检测相机权限
- (BOOL)checkAuthorityOfCamera{
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
        //无权限

        [self showAlertWithMessage:@"相机被禁止访问了，请前往设置进行更改" ];
        return NO;

    }
   
    return YES;
   
}
- (void)showAlertWithMessage:(NSString *)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
    }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}
@end
