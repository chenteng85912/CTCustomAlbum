//
//  UIAlertController+TYKYAlertBlock.h
//

#import <UIKit/UIKit.h>

typedef void (^CTAlertTouchBlock)(NSInteger buttonIndex);

@interface UIAlertController (TYKYAlertBlock)

/**
 *title 提示标题
 *message 提示语
 *cancelButtonTitle 取消按钮
 *otherButtonTitles 其他按钮数组
 *alertStyle alert样式
 */

+ (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
     cancelButtonTitle:(NSString *)cancelButtonTitle
     otherButtonTitles:(NSArray <NSString *>*)otherButtonTitles
        preferredStyle:(UIAlertControllerStyle)alertStyle
                 block:(CTAlertTouchBlock)block;

@end
