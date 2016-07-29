//
//  ONEPhoto.h
//  FacePk
//
//  Created by Apple on 16/7/15.
//  Copyright © 2016年 腾. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ONEPhotoDelegate <NSObject>

- (void)sendOnePhoto:(UIImage *)image;

@end

@interface ONEPhoto : NSObject
@property (nonatomic,weak) id <ONEPhotoDelegate> delegate;

+ (ONEPhoto *)shareSigtonPhoto;
- (void)openCamera:(UIViewController *)rootVC editModal:(BOOL)enableEdit;
- (void)openAlbum:(UIViewController *)rootVC editModal:(BOOL)enableEdit;
@end
