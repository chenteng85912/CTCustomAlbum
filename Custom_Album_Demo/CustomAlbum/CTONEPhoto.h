//
//  ONEPhoto.h
//  FacePk
//
//  Created by Apple on 16/7/15.
//  Copyright © 2016年 腾. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CTONEPhotoDelegate <NSObject>

- (void)sendOnePhoto:(UIImage *)image;

@end

@interface CTONEPhoto : NSObject
@property (nonatomic,weak) id <CTONEPhotoDelegate> delegate;

+ (CTONEPhoto *)shareSigtonPhoto;

//打开系统摄像头
- (void)openCamera:(UIViewController *)rootVC editModal:(BOOL)enableEdit;
//打开系统相册
- (void)openAlbum:(UIViewController *)rootVC editModal:(BOOL)enableEdit;
@end
