//
//  NSTheadDemo.m
//  GCD-iOS
//
//  Created by ShanCheli on 2017/12/13.
//  Copyright © 2017年 ShanCheli. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "NSTheadDemo.h"

@implementation NSTheadDemo


- (void)ThreadDemo {
    NSLog(@"hello %@",[NSThread currentThread]);
    BOOL isMainA = [NSThread isMainThread];
    NSLog(@"是否在主线程 --%d", isMainA);
    
    // 1、NSThread
    [self NSThreadDemo];
}

#pragma mark-  NSThread
- (void)NSThreadDemo {
    
    // 一、创建线程的 三种方法   每个对象表示一条线程.
    
    // 1、对象方法  实例化线程对象的同时指定线程执行的方法@selector(demo:). 需要手动开启线程
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(demo:) object:@"alloc"];
    
    // 设置线程的name
    thread.name = @"子线程A";
    
    // 设置线程的优先级 数字越小 优先级越低
    thread.threadPriority = 0.1;
    
    // 是否是在主线程
    BOOL isMainB = [thread isMainThread];
    NSLog(@"是否在主线程 --%d", isMainB);
    
    // 手动启动线程  将线程放进可调度线程池,等待被CPU调度
    [thread start];
    
    // 2、类方法   分离出一个线程,并且自动开启线程执行@selector(demo:) 无法获取到线程对象
    [NSThread detachNewThreadSelector:@selector(demo:) toTarget:self withObject:@"detach"];
    
    // 3、NSObject(NSThreadPerformAdditions) 的分类创建
    // 方便任何继承自NSObject的对象,都可以很难容易的调用线程方法
    // 无法获取到线程对象
    [self performSelectorInBackground:@selector(demo:) withObject:@"perform"];
    
    // 二、阻塞
    
    // 正在运行的线程,当满足某个条件时,可以用休眠或者锁来阻塞线程的执行
    // sleepForTimeInterval:休眠指定时长
    [NSThread sleepForTimeInterval:1.0];
    
    // sleepUntilDate:休眠到指定日期
    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    
    // 互斥锁
    //  @synchronized(self);
    
    // 三、死亡 线程结束
    
    // 主线程中的危险操作,不能在主线程中调用该方法.会使主线程退出  线程一旦进入到死亡状态, 线程也就停止了, 就不能再次启动任务.
    [NSThread exit];
    
    // 四、线程间通信
    // - (void)performSelectorOnMainThread:(SEL)aSelector withObject:(nullable id)arg waitUntilDone:(BOOL)wait;
    // - (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(nullable id)arg waitUntilDone:(BOOL)wait;
    [self download];
}


#pragma mark-  互斥锁 和 原子属性
- (void)SynchronizedDemo {
    
    // 互斥锁,就是使用了线程同步技术.
    // 同步锁/互斥锁:可以保证被锁定的代码,同一时间,只能有一个线程可以操作.
    // self :锁对象,任何继承自NSObject的对像都可以是锁对象,因为内部都有一把锁,而且默认是开着的.
    // 锁对象 : 一定要是全局的锁对象,要保证所有的线程都能够访问,self是最方便使用的锁对象.
    // 互斥锁锁定的范围应该尽量小,但是一定要锁住资源的读写部分.
    // 加锁后程序执行的效率比不加锁的时候要低.因为线程要等待解锁.
    // 牺牲了性能保证了安全性.
    [self demo:nil];
    
    
    // nonatomic : 非原子属性
    // atomic : 原子属性
    // 线程安全的,针对多线程设计的属性修饰符,是默认值.
    // 保证同一时间只有一个线程能够写入,但是同一个时间多个线程都可以读取.
    // **单写多读 : ** 单个线程写入write,多个线程可以读取read.
    // atomic 本身就有一把锁,自旋锁.
    
    // nonatomic和atomic对比
    // nonatomic : 非线程安全,适合内存小的移动设备.
    // atomic : 线程安全,需要消耗大量的资源.性能比非原子属性要差.
    
    // iOS开发的建议
    // 所有属性都声明为nonatomic,性能更高.
    // 尽量避免多线程抢夺同一块资源.
    // 尽量将加锁、资源抢夺的业务逻辑交给服务器端处理，减小移动客户端的压力.
    
    
    
    // 互斥锁和自旋锁对比
    
    // 共同点
    // 都能够保证同一时间,只有一条线程执行锁定范围的代码
    
    // 不同点
    // 互斥锁:如果发现有其他线程正在执行锁定的代码,线程会进入休眠状态,等待其他线程执行完毕,打开锁之后,线程会重新进入就绪状态.等待被CPU重新调度.
    // 自旋锁:如果发现有其他线程正在执行锁定的代码,线程会以死循环的方式,一直等待锁定代码执行完成.
    
}



// 互斥锁
- (void)demo:(id)object {
    
    NSInteger tickets = 0;
    
    // while 循环保证每个窗口都可以单独把所有的票卖完
    while (YES) {
        // 模拟休眠网络延迟
        [NSThread sleepForTimeInterval:1.0];
        
        // 添加互斥锁
        @synchronized(self) {
            // 判断是否有票
            if (tickets>0) {
                // 有票就卖
                tickets--;
                // 卖完一张票就提示用户余票数
                NSLog(@"剩余票数 => %zd",tickets);
            } else {
                // 没有就提示用户
                NSLog(@"没票了");
                // 此处要结束循环,不然会死循环
                break;
            }
        }
    }
}


#pragma mark- NSThread线程间通信 异步下载图片
- (void)download {
    
    // 网络图片 URL
    NSURL *url = [NSURL URLWithString:@"http://pic1.win4000.com/wallpaper/2/4fcec0bf0fb7f.jpg"];
    
    // 根据 URL 下载图片到本地, 保存为二进制文件
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    // 转换图片格式
    UIImage *image = [UIImage imageWithData:data];
    
    // 查看当前线程
    NSLog(@"download - %@", [NSThread currentThread]);
    
    // 在子线程下载后要回到主线程设置 UI
    /*
     第一个参数: 回到主线程之后要调用哪个方法
     第二个参数: 调用方法要传递的参数
     第三个参数: 是否需要等待该方法执行完毕再往下执行
     */
    [self performSelectorOnMainThread:@selector(demo:) withObject:image waitUntilDone:YES];
    [self performSelector:@selector(demo:) onThread:[NSThread mainThread] withObject:image waitUntilDone:YES];
    
}








@end
