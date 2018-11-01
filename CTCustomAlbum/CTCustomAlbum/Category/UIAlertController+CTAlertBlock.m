//
//  UIAlertController+TYKYAlertBlock.m
//

#import "UIAlertController+CTAlertBlock.h"

@implementation UIAlertController (CTAlertBlock)

+ (void)alertWithTitle:(NSString *)title
             message:(NSString *)message
   cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitles:(NSArray <NSString *>*)otherButtonTitles
      preferredStyle:(UIAlertControllerStyle)alertStyle
               block:(CTAlertTouchBlock)block{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:alertStyle];
    if (cancelButtonTitle) {
        [alert addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (block) {
                block(0);
            }
        }]];
    }
    
    for (int i=0; i<otherButtonTitles.count; i++) {
        NSString *title = otherButtonTitles[i];
        UIAlertActionStyle style = UIAlertActionStyleDefault;
        if (i==0) {
            style = UIAlertActionStyleDestructive;
        }
        [alert addAction:[UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction * _Nonnull action) {
            if (block) {
                block(i+1);
            }
        }]];
    }
    
    UIViewController *rootVC = [self p_currentViewController];
    if (rootVC) {
        [rootVC presentViewController:alert animated:YES completion:nil];
    }

}
//获取最顶部控制器
+ (UIViewController *)p_currentViewController {
    
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1) {
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
