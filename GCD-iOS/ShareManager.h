//
//  ShareManager.h
//  GCD-iOS
//
//  Created by ShanCheli on 2017/12/12.
//  Copyright © 2017年 ShanCheli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareManager : NSObject

@property (nonatomic, copy) NSString *someProperty;
+ (ShareManager *)shareManager;
+ (ShareManager *)sharedManager;

@end
