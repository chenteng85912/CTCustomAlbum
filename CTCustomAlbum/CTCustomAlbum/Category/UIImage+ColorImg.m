//
//  UIImage+ColorImg.m
//  CTCustomAlbum
//
//  Created by 陈腾 on 2018/4/11.
//  Copyright © 2018年 陈腾. All rights reserved.
//

#import "UIImage+ColorImg.h"
#import <AVFoundation/AVFoundation.h>

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
//正常摆正图片方向
- (UIImage *)normalizedImage {
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [normalizedImage fixOrientation];
}
//获取视频截图
+ (UIImage *)getVideoShotImage:(NSURL *)videoUrl {
    
    UIImage *shotImage;
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    shotImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return shotImage;
}
//** 纠正图片的方向 */
- (UIImage *)fixOrientation {
    if (self.imageOrientation == UIImageOrientationUp){
        
        return self;
    }
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}

/** 按给定的方向旋转图片 */
- (UIImage*)rotate:(UIImageOrientation)orient {
    CGRect bnds = CGRectZero;
    UIImage* copy = nil;
    CGContextRef ctxt = nil;
    CGImageRef imag = self.CGImage;
    CGRect rect = CGRectZero;
    CGAffineTransform tran = CGAffineTransformIdentity;
    
    rect.size.width = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    
    bnds = rect;
    
    switch (orient)
    {
        case UIImageOrientationUp:
            return self;
            
        case UIImageOrientationUpMirrored:
            tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown:
            tran = CGAffineTransformMakeTranslation(rect.size.width,
                                                    rect.size.height);
            tran = CGAffineTransformRotate(tran, M_PI);
            break;
            
        case UIImageOrientationDownMirrored:
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            tran = CGAffineTransformScale(tran, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeft:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeftMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height,
                                                    rect.size.width);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeScale(-1.0, 1.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        default:
            return self;
    }
    
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
    
    switch (orient)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextScaleCTM(ctxt, -1.0, 1.0);
            CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
            break;
            
        default:
            CGContextScaleCTM(ctxt, 1.0, -1.0);
            CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
            break;
    }
    
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return copy;
}
+ (UIImage *)vectorImageWithName:(NSString *)name size:(CGSize)size stretch:(BOOL)stretch {
    // PDF 文件路径
    NSString *path = [NSBundle.mainBundle pathForResource:name ofType:@"pdf"];
    NSLog(@"图标名称%@",name);
    NSAssert(path, @"Vector image file path should NOT be nil");
    if (!path) return nil;
    return [self p_vectorImageWithURL:[NSURL fileURLWithPath:path] size:size stretch:stretch page:1];
}
+ (UIImage *)p_vectorImageWithURL:(NSURL *)url size:(CGSize)size stretch:(BOOL)stretch page:(NSUInteger)page {
    
    CGFloat screenScale = UIScreen.mainScreen.scale;
    // PDF 源文件
    CGPDFDocumentRef pdfRef = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    // PDF 中的一页
    CGPDFPageRef imagePage = CGPDFDocumentGetPage(pdfRef, page);
    // PDF 这一页显示出来的 CGRect
    CGRect pdfRect = CGPDFPageGetBoxRect(imagePage, kCGPDFCropBox);
    // 传入的大小如果为零，使用 PDF 原图大小
    CGSize contextSize = (size.width <= 0 || size.height <= 0) ? pdfRect.size : size;
    // RGB 颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 位图上下文
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 contextSize.width * screenScale,
                                                 contextSize.height * screenScale,
                                                 8,
                                                 0,
                                                 colorSpace,
                                                 kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    // 坐标缩放，增加清晰度
    CGContextScaleCTM(context, screenScale, screenScale);
    
    if (size.width > 0 && size.height > 0) {
        // 指定图片大小，需要缩放图片
        // 计算宽高缩放比
        CGFloat widthScale = size.width / pdfRect.size.width;
        CGFloat heightScale = size.height / pdfRect.size.height;
        
        if (!stretch) {
            // 保持原图宽高比，使用宽高缩放比中的最小值
            heightScale = MIN(widthScale, heightScale);
            widthScale = heightScale;
            // 坐标平移，使图片居中
            CGFloat currentRatio = size.width / size.height;
            CGFloat realRatio = pdfRect.size.width / pdfRect.size.height;
            if (currentRatio < realRatio) {
                CGContextTranslateCTM(context, 0, (size.height - size.width / realRatio) / 2);
            } else {
                CGContextTranslateCTM(context, (size.width - size.height * realRatio) / 2, 0);
            }
        }
        // 用以上宽高缩放比缩放坐标
        CGContextScaleCTM(context, widthScale, heightScale);
        
    } else {
        // 使用原图大小
        // 获取原图坐标转换矩阵，用于位图上下文
        CGAffineTransform drawingTransform = CGPDFPageGetDrawingTransform(imagePage, kCGPDFCropBox, pdfRect, 0, true);
        CGContextConcatCTM(context, drawingTransform);
    }
    // 把 PDF 中的一页绘制到位图
    CGContextDrawPDFPage(context, imagePage);
    CGPDFDocumentRelease(pdfRef);
    // 创建 UIImage
    CGImageRef image = CGBitmapContextCreateImage(context);
    UIImage *pdfImage = [[UIImage alloc] initWithCGImage:image scale:screenScale orientation:UIImageOrientationUp];
    // 释放资源
    CGImageRelease(image);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return pdfImage;
}
/** 交换宽和高 */
static CGRect swapWidthAndHeight(CGRect rect) {
    CGFloat swap = rect.size.width;
    
    rect.size.width = rect.size.height;
    rect.size.height = swap;
    
    return rect;
}
@end
