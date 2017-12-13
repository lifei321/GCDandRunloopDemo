//
//  ShareManager.m
//  GCD-iOS
//
//  Created by ShanCheli on 2017/12/12.
//  Copyright © 2017年 ShanCheli. All rights reserved.
//

#import "ShareManager.h"

@implementation ShareManager


static ShareManager *sharedManager = nil;
//GCD实现单例功能
+ (ShareManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

//在ARC下，非GCD，实现单例功能
+ (ShareManager *)sharedManager
{
    @synchronized(self) {
        if (!sharedManager) {
            sharedManager = [[self alloc] init];
        }
    }
    return sharedManager;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        _someProperty = @"Default Property Value";
    }
    return self;
}

@end
