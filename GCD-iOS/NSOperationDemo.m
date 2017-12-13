//
//  NSOperationDemo.m
//  GCD-iOS
//
//  Created by ShanCheli on 2017/12/13.
//  Copyright © 2017年 ShanCheli. All rights reserved.
//

#import "NSOperationDemo.h"
#import <UIKit/UIKit.h>

@implementation NSOperationDemo

#pragma mark-  NSOpeartion
- (void)NSOperationDemo {
    
    // NSOperation是苹果提供给我们的一套多线程解决方案。实际上NSOperation是基于GCD更高一层的封装，但是比GCD更简单易用、代码可读性也更高。
    
    // NSOperation需要配合NSOperationQueue来实现多线程。因为默认情况下，NSOperation单独使用时系统同步执行操作，并没有开辟新线程的能力，只有配合NSOperationQueue才能实现异步执行。
    
    // NSOperation实现多线程的使用步骤分为三步：
    
    // 创建任务：先将需要执行的操作封装到一个NSOperation对象中。
    // 创建队列：创建NSOperationQueue对象。
    // 将任务加入到队列中：然后将NSOperation对象添加到NSOperationQueue中。  之后呢，系统就会自动将NSOperationQueue中的NSOperation取出来，在新线程中执行操作。
    
    // 一、创建任务
    
    //      1、使用子类 NSInvocationOperation 创建
    //         在没有使用NSOperationQueue、单独使用NSInvocationOperation的情况下，NSInvocationOperation在主线程执行操作，并没有开启新线程
            NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(run) object:nil];
    
            // 调用start方法开始执行操作
            [op start];
    
    //       2、使用子类- NSBlockOperation 创建任务  也不会开辟新的线程 还是在主线程执行
             NSBlockOperation *blockop = [NSBlockOperation blockOperationWithBlock:^{
                 // 在主线程
                 NSLog(@"------%@", [NSThread currentThread]);
             }];
    
            [blockop start];
    
    //      NSBlockOperation 通过addExecutionBlock 添加额外的任务(在子线程执行)  这时就可以在子线程并发执行
            [blockop addExecutionBlock:^{
                NSLog(@"2------%@", [NSThread currentThread]);
            }];
            [blockop addExecutionBlock:^{
                NSLog(@"3------%@", [NSThread currentThread]);
            }];
            [blockop addExecutionBlock:^{
                NSLog(@"4------%@", [NSThread currentThread]);
            }];
    
            [blockop start];
    
    //      3、定义继承自NSOperation的子类 创建任务
    //          先定义一个继承自NSOperation的子类
    
    // 二、创建队列
    // NSOperationQueue一共有两种队列：主队列、其他队列。其中其他队列同时包含了串行、并发功能。下边是主队列、其他队列的基本创建方法和特点。
    
    //          1、主队列  凡是添加到主队列中的任务（NSOperation），都会放到主线程中执行
                NSOperationQueue *queue = [NSOperationQueue mainQueue];
                NSLog(@"%@", queue);
    
    //          2、其他队列  添加到这种队列中的任务（NSOperation），就会自动放到子线程中执行  同时包含了：串行、并发功能
                NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
                NSLog(@"%@", queue2);

    // 三、 将任务加入到队列中
    //        1、普通方式
                [self addOperationToQueue];
    
    //        2、block方式
                [self addOperationWithBlockToQueue];
    
    // 四、 控制串行执行和并行执行的关键
    //       最大并发数：maxConcurrentOperationCount
    //       maxConcurrentOperationCount默认情况下为-1，表示不进行限制，默认为并发执行。
    //       当maxConcurrentOperationCount为1时，进行串行执行。
    //       当maxConcurrentOperationCount大于1时，进行并发执行，当然这个值不应超过系统限制，即使自己设置一个很大的值，系统也会自动调整。
    
    
    // 五、 操作依赖
    //      NSOperation和NSOperationQueue最吸引人的地方是它能添加操作之间的依赖关系。比如说有A、B两个操作，其中A执行完操作，B才能执行操作，那么就需要让B依赖于A。
            [self addDependency];
            [self addDependency2];
    
    // 六、 其他的一些方法
    
    //       - (void)cancel; NSOperation提供的方法，可取消单个操作
    
    //       - (void)cancelAllOperations; NSOperationQueue提供的方法，可以取消队列的所有操作
    
    //       - (void)setSuspended:(BOOL)b; 可设置任务的暂停和恢复，YES代表暂停队列，NO代表恢复队列
    
    //       - (BOOL)isSuspended; 判断暂停状态
    
    // 七、线程间通信
            [self downLoadImage];
    
}

- (void)addOperationToQueue {
    
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2. 创建操作
    // 创建NSInvocationOperation
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(run) object:nil];
    // 创建NSBlockOperation
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; ++i) {
            NSLog(@"1-----%@", [NSThread currentThread]);
        }
    }];
    
    // 3. 添加操作到队列中：addOperation:
    [queue addOperation:op1]; // [op1 start]
    [queue addOperation:op2]; // [op2 start]
}

- (void)run
{
    for (int i = 0; i < 2; ++i) {
        NSLog(@"2-----%@", [NSThread currentThread]);
    }
}


- (void)addOperationWithBlockToQueue {
    
    // 1. 创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2. 添加操作到队列中：addOperationWithBlock:
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; ++i) {
            NSLog(@"-----%@", [NSThread currentThread]);
        }
    }];
}


#pragma mark- 操作依赖
- (void)addDependency
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    
    __block UIImage *image1 = nil;
    __block UIImage *image2 = nil;
    // 1.开启一个线程下载第一张图片
    NSOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSURL *url = [NSURL URLWithString:@"http://cdn.cocimg.com/assets/images/logo.png?v=201510272"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        // 2.生成下载好的图片
        UIImage *image = [UIImage imageWithData:data];
        image1 = image;
    }];
    
    // 2.开启一个线程下载第二长图片
    NSOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSURL *url = [NSURL URLWithString:@"https://www.baidu.com/img/bd_logo1.png"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        // 2.生成下载好的图片
        UIImage *image = [UIImage imageWithData:data];
        image2 = image;
        
    }];
    // 3.开启一个线程合成图片
    NSOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        UIGraphicsBeginImageContext(CGSizeMake(200, 200));
        [image1 drawInRect:CGRectMake(0, 0, 100, 200)];
        [image2 drawInRect:CGRectMake(100, 0, 100, 200)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        NSLog(@"%@", newImage);

        UIGraphicsEndImageContext();
        
        // 4.回到主线程更新UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"回到主线程更新UI");
//            self.imageView.image = newImage;
        }];
    }];
    
    
    // 监听任务是否执行完毕
    op1.completionBlock = ^{
        NSLog(@"第一张图片下载完毕");
    };
    op2.completionBlock = ^{
        NSLog(@"第二张图片下载完毕");
    };
    
    // 添加依赖
    // 只要添加了依赖, 那么就会等依赖的任务执行完毕, 才会执行当前任务
    // 注意:
    // 1.添加依赖, 不能添加循环依赖
    // 2.NSOperation可以跨队列添加依赖
    [op3 addDependency:op1];
    [op3 addDependency:op2];
    
    // 将任务添加到队列中
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue2 addOperation:op3];
}

- (void)addDependency2
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1-----%@", [NSThread  currentThread]);
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"2-----%@", [NSThread  currentThread]);
    }];
    
    [op2 addDependency:op1];    // 让op2 依赖于 op1，则先执行op1，在执行op2
    
    [queue addOperation:op1];
    [queue addOperation:op2];
}

#pragma mark- 线程间通信
- (void)downLoadImage {
    // 1.开启子线程下载图片
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        // 子线程
        NSString *urlStr = @"https://www.baidu.com/img/bd_logo1.png";
        // url中文编码，防止乱码
        // urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSData *data = [NSData dataWithContentsOfURL:url];
        // 2.生成下载好的图片
        UIImage *image = [UIImage imageWithData:data];
        NSLog(@"%@", image);

        // 3.回到主线程更新UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"更新UI");
            // 主线程
//            self.imageView.image = image;
        }];
    }];
}

@end
