//
//  SaveImageTool.m
//  webhall
//
//  Created by chenteng on 2016/12/21.
//

#import "CTSavePhotos.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <Photos/Photos.h>

@implementation CTSavePhotos

//检测相册权限
+ (BOOL)checkAuthorityOfAblum{
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        [self p_showAlertWithMessage:@"相册被禁止访问了，请前往设置进行更改" ];
        
        return NO ;
    }
    
    return YES;
    
}
//检测相机权限
+ (BOOL)checkAuthorityOfCamera{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"没有可调用的相机");
        return NO;
    }
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied)
    {
        [self p_showAlertWithMessage:@"相机被禁止访问了，请前往设置进行更改" ];
        return NO;
    }
    
    return YES;
    
}

//保存图片到相册
+ (void)saveImageIntoAlbum:(UIImage *)image{
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        // 1.创建图片请求类(创建系统相册中新的图片)PHAssetCreationRequest
        PHAssetCreationRequest *assetCreationRequest = [PHAssetCreationRequest creationRequestForAssetFromImage:image];
        
        // 2.创建相册请求类(修改相册)PHAssetCollectionChangeRequest
        PHAssetCollectionChangeRequest *assetCollectionChangeRequest = nil;
        
        // 获取之前相册
        PHAssetCollection *assetCollection = [self p_fetchAssetCollection];
        // 判断是否已有相册
        if (assetCollection) {
            // 如果存在已有同名相册   指定这个相册,创建相册请求修改类
            assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        } else {
            //不存在,创建新的相册
            assetCollectionChangeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:self.APPNAME];
        }
        // 3.把图片添加到相册中
        [assetCollectionChangeRequest addAssets:@[assetCreationRequest.placeholderForCreatedAsset]];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        if (success) {
            NSLog(@"图片保存成功");
        }
        
    }];

}
// 指定相册名称,获取相册
+ (PHAssetCollection *)p_fetchAssetCollection
{
    // 获取相簿中所有自定义相册
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                     subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    //遍历相册,判断是否存在同名的相册
    PHAssetCollection *assetCol = nil;
    for (PHAssetCollection *assetCollection in result) {
        if ([self.APPNAME isEqualToString:assetCollection.localizedTitle]) {
            //存在,就返回这个相册
            assetCol = assetCollection;
            break;
        }
    }
    return assetCol;
}


//弹出前往设置提示
+ (void)p_showAlertWithMessage:(NSString *)msg{

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            
            [[UIApplication sharedApplication] openURL:url];
            
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self.p_currentViewController presentViewController:alert animated:YES completion:nil];
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
//获取项目名称 作为相册分类
+ (NSString *)APPNAME{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    return appName;
}

@end
