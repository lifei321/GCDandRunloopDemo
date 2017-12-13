//
//  ViewController.m
//  GCD-iOS
//
//  Created by ShanCheli on 2017/12/12.
//  Copyright © 2017年 ShanCheli. All rights reserved.
//

#import "ViewController.h"
#import "NSTheadDemo.h"
#import "GCDDemo.h"
#import "NSOperationDemo.h"
#import "RunLoopDemo.h"

@interface ViewController ()




@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"hello %@",[NSThread currentThread]);
    BOOL isMainA = [NSThread isMainThread];
    NSLog(@"是否在主线程 --%d", isMainA);
    
    // 1、NSThread
    [[[NSTheadDemo alloc] init] NSThreadDemo];
    
    // 2、GCD
    [[[GCDDemo alloc] init] GCD_Demo];
    
    // 3、NSOperation
    [[[NSOperationDemo alloc] init] NSOperationDemo];
    
    // 4、互斥锁  解决多线程操作共享资源的问题
    [[[NSTheadDemo alloc] init] SynchronizedDemo];
    
    // 5、runloop
    [[[RunLoopDemo alloc] init] runLoopDemo];
}





















@end
