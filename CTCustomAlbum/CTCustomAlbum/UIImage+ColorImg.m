//
//  UIImage+ColorImg.m
//  CTCustomAlbum
//
//  Created by 陈腾 on 2018/4/11.
//  Copyright © 2018年 陈腾. All rights reserved.
//

#import "UIImage+ColorImg.h"

@implementation UIImage (ColorImg)

+ (instancetype)imageFromColor:(UIColor *)color size:(CGSize)size {
    
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}

@end
