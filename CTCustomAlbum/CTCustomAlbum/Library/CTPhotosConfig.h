//
//  CTPhotosConfig.h
//
//  Created by chenteng on 2017/12/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#ifndef CTPhotosConfig_h
#define CTPhotosConfig_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "CTSavePhotos.h"
#import "CTPhotosConfiguration.h"
#import "CTPHAssetModel.h"
#import "UIButton+CTButtonManager.h"
#import "UIAlertController+CTAlertBlock.h"
#import "NSTimer+timerBlock.h"
#import "UIImage+ColorImg.h"

#define WEAKSELF    __weak typeof(self) weakSelf = self

#define kDevice_height   [[UIScreen mainScreen] bounds].size.height
#define kDevice_width    [[UIScreen mainScreen] bounds].size.width
#define kKeyWindow       [UIApplication sharedApplication].keyWindow
#define iPhoneX          [UIScreen mainScreen].bounds.size.height >= 812
//导航栏高度
#define NAVBAR_HEIGHT     ([[UIApplication sharedApplication] statusBarFrame].size.height+44)
#define kTabBarHeight     (iPhoneX ? 83 : 49)
#define kSystemFont(font)         [UIFont systemFontOfSize:font]
#define kColorValue(rgbValue)     [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kMAINCOLOR                kColorValue(0x3E59CC)
#define kImage(name,width,height)         [UIImage vectorImageWithName:name size:CGSizeMake(width, height) stretch:NO]

@class CTPHAssetModel;
typedef void (^CTCustomMediasBLock)(NSArray <CTPHAssetModel *>*mediasArray);
typedef void (^CTTouchBtnBlock)(NSInteger index);

#endif /* CTPhotosConfig_h */
