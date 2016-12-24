//
//  SaveImageTool.h
//  webhall
//
//  Created by Apple on 2016/12/21.
//  Copyright © 2016年 深圳太极软件有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CTSavePhotos : NSObject

//保存图片到相册 自定义分类名称
- (void)saveImageIntoAlbum:(UIImage *)image;

//判断相机权限
- (BOOL)checkAuthorityOfAblum;

//检测相机权限
- (BOOL)checkAuthorityOfCamera;
@end
