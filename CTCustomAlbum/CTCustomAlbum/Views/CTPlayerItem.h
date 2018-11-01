//
//  LQPlayerItem.h
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/7/2.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface CTPlayerItem : AVPlayerItem

- (void)LQAddObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;

- (void)LQRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end
