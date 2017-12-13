//
//  GCDDemo.m
//  GCD-iOS
//
//  Created by ShanCheli on 2017/12/13.
//  Copyright © 2017年 ShanCheli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDDemo.h"
#import "ShareManager.h"



@implementation GCDDemo


#pragma mark-  GCD
- (void)GCD_Demo {
    
    // 什么是 GCD 全称是 Grand Central Dispatch  纯 C语言, 提供了非常强大的函数
    // GCD 中有两个核心概念   1、任务: 执行什么操作   2、队列: 用来仿什么任务
    
    // 一、 核心概念
    //      1、任务的执行方式 有两种 ： 同步 和 异步
    //      2、队列的类型 有两种 ： 串行 和 并列
    
    // 二、队列
    //      1、并行队列
    dispatch_queue_t queue = dispatch_queue_create("abc", DISPATCH_QUEUE_CONCURRENT);
    
    // 第一个参数是队列优先级, 第二个参数一般都是0, 没什么用
    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //       2、串行队列
    
    // 第二个队列类型可以传 NULL 或者 DISPATCH_QUEUE_SERIAL 效果是一样的
    dispatch_queue_t queue3 = dispatch_queue_create("abc", DISPATCH_QUEUE_SERIAL);
    NSLog(@"%@", queue3);
    
    dispatch_queue_t queue4 = dispatch_get_main_queue();
    NSLog(@"%@", queue4);
    
    
    // 三、 任务
    //      1、同步的方式   只能在当前线程中执行任务, 不具备开新启线程的能力  同步函数是不会开启子线程的, 所有任务都是在主线程中串行执行的.
            dispatch_sync( queue, ^{
                // block 内容
            });
    
    //      2、异步的方式  可以在新的线程中执行任务, 具备开启新线程的能力
            dispatch_async( queue2, ^{
                // block 内容
            });
    
    // 四、一个特殊的函数调用  同步函数调用主队列问题
    [self syncMain];
    
    // 五、GCD 线程间通信
    [self GCD_downloadImage];
    
    // 六、 GCD 常用函数
    [self GCD_CommonFunction];
    
    // 单例
    [self GCD_shareManager];
    
    // GCD的栅栏方法
    [self GCD_ZHALAN];
    
    // 七、 GCD 队列组
    [self GCD_Group];
    
}



#pragma mark- 一个特殊的死循环 同步函数在主队列运行

// 打印结果: 2016-07-28 12:02:20.473 GCD[21183:1395248] ---start---
// 主线程发现有任务, 就要让主线程去执行任务, 但此时的主线程却在等待这任务执行完毕, 不是空闲状态, 所以主线程无法执行任务, 形成死锁. 而同步函数又要求任务要立刻马上按顺序执行, 所以第一个任务执行不了, 后面的当然也执行不了 , 就卡在了那里.

// 解决办法： [NSThread detachNewThreadSelector:@selector(syncMain) toTarget:self withObject:nil];
// 打印结果： 2016-07-28 12:17:01.477 GCD[21971:1403347] ---start---
//          2016-07-28 12:17:01.481 GCD[21971:1403123] download1- <NSThread: 0x7fca2bc02470>{number = 1, name = main}
//          2016-07-28 12:17:01.500 GCD[21971:1403123] download2- <NSThread: 0x7fca2bc02470>{number = 1, name = main}
//          2016-07-28 12:17:01.503 GCD[21971:1403123] download3- <NSThread: 0x7fca2bc02470>{number = 1, name = main}
//          2016-07-28 12:17:01.504 GCD[21971:1403347] ---end---

// 发现已经全部执行完毕了, 而且是在主线程中执行的. 这是因为我们是开启的子线程来调用方法, 此时的主线程是空闲的, 然后方法中的任务需要在主线程中执行, 就没有问题了.


- (void)syncMain {
    
    NSLog(@"---start---");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_sync(queue, ^{
        
        NSLog(@"download1- %@", [NSThread currentThread]);
        
    });
    
    dispatch_sync(queue, ^{
        
        NSLog(@"download2- %@", [NSThread currentThread]);
        
    });
    
    dispatch_sync(queue, ^{
        
        NSLog(@"download3- %@", [NSThread currentThread]);
        
    });
    
    NSLog(@"---end---");
}


#pragma mark- gcd 线程间通信 异步下载图片
- (void)GCD_downloadImage {
    
    // 开启子线程下载图片
    // dispatch_sync 和 dispatch_async 两者效果一样,因为是在子线程下载的
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 网络图片 url
        NSURL *url = [NSURL URLWithString:@"http://pic12.nipic.com/20110114/6621051_221433460330_2.jpg"];
        
        // 下载二进制数据到本地
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        // 获取图片
        UIImage *image = [[UIImage alloc] initWithData:data];
        NSLog(@"%@", image);
        
        // 回到主线程刷新 UI 图片
        dispatch_async(dispatch_get_main_queue(), ^{
            //            self.imageView.image = image;
        });
        
    });
}

#pragma mark- GCD常用函数
- (void)GCD_CommonFunction {
    
    // 1、delay 延迟操作
    [self performSelector:@selector(task) withObject:nil afterDelay:3.0];
    
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC));
    
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        NSLog(@"GCD-%@", [NSThread currentThread]);
    });
    
    dispatch_after(delay, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"GCD-%@", [NSThread currentThread]);
    });
    
    // 2、once 一次性执行
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"once - %@", [NSThread currentThread]);
    });
    
    
    // 3、循环执行一个block  快速迭代 相当于for循环
    //     dispatch_apply在给定的队列上多次执行某一任务，在主线程直接调用会阻塞主线程去执行block中的任务。
    //     dispatch_apply函数的功能：把一项任务提交到队列中多次执行，队列可以是串行也可以是并行，dispatch_apply不会立刻返回，在执行完block中的任务后才会返回，是同步执行的函数。
    //     dispatch_apply正确使用方法：为了不阻塞主线程，一般把dispatch_apply放在异步队列中调用，然后执行完成后通知主线程
    //     嵌套使用dispatch_apply会导致死锁。
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{
        dispatch_queue_t applyQueue = dispatch_get_global_queue(0, 0);
        //第一个参数，3--block执行的次数
        //第二个参数，applyQueue--block任务提交到的队列
        //第三个参数，block--需要重复执行的任务
        dispatch_apply(3, applyQueue, ^(size_t index) {
            NSLog(@"current index %@",@(index));
            sleep(1);
        });
        NSLog(@"dispatch_apply 执行完成");
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            NSLog(@"回到主线程更新UI");
        });
    });
    
}

#pragma mark- 单例的实现方式
- (void)GCD_shareManager {
    
    [ShareManager shareManager];
    [ShareManager sharedManager];
    
}

#pragma mark- GCD 栅栏方法
- (void)GCD_ZHALAN {
    
    // 我们有时需要异步执行两组操作，而且第一组操作执行完之后，才能开始执行第二组操作。这样我们就需要一个相当于栅栏一样的一个方法将两组异步执行的操作组给分割起来，当然这里的操作组里可以包含一个或多个任务。
    // 下面代码 执行结果： 1 2 barrier 3 4
    dispatch_queue_t queue = dispatch_queue_create("12312312", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        NSLog(@"----1-----%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"----2-----%@", [NSThread currentThread]);
    });
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"----barrier-----%@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"----3-----%@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"----4-----%@", [NSThread currentThread]);
    });
}

#pragma mark- GCD队列组
- (void)GCD_Group {
    
    // 有时候我们会有这样的需求：分别异步执行2个耗时操作，然后当2个耗时操作都执行完毕后再回到主线程执行操作。这时候我们可以用到GCD的队列组。
    // 我们可以先把任务放到队列中，然后将队列放入队列组中。
    // 调用队列组的dispatch_group_notify回到主线程执行操作。
    
    dispatch_group_t group =  dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 执行1个耗时的异步操作
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 执行1个耗时的异步操作
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步操作都执行完毕后，回到主线程...
    });
    
}













@end
