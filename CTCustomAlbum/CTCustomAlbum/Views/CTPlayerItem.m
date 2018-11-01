//
//  LQPlayerItem.m
//  qizhiyun_client
//
//  Created by 陈腾 on 2018/7/2.
//  Copyright © 2018年 starxin. All rights reserved.
//

#import "CTPlayerItem.h"

@interface CTPlayerItem ()
@property (nonatomic, assign) BOOL isAddObserver;
@property (nonatomic, strong) NSLock *lock;

@end
@implementation CTPlayerItem

- (instancetype)initWithURL:(NSURL *)URL {
    
    if (self = [super initWithURL:URL]) {
        _lock = NSLock.new;
    }
    return self;
}

- (void)LQAddObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    [self.lock lock];
    if (!_isAddObserver) {
        
        [self addObserver:observer forKeyPath:keyPath options:options context:context];
        _isAddObserver = YES;
    }
    [self.lock unlock];
}
- (void)LQRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    [self.lock lock];
    if (_isAddObserver) {
        [self removeObserver:observer forKeyPath:keyPath];
        _isAddObserver = NO;
        
    }
    [self.lock unlock];
}
@end
