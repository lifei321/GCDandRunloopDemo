//
//  RunLoopDemo.m
//  GCD-iOS
//
//  Created by ShanCheli on 2017/12/13.
//  Copyright © 2017年 ShanCheli. All rights reserved.
//

#import "RunLoopDemo.h"
#import <UIKit/UIKit.h>

@interface RunLoopDemo()

@property (strong, nonatomic) NSThread *thread;

@end

@implementation RunLoopDemo

- (void)runLoopDemo {
    
    // 一、 什么是RunLoop
    //      RunLoop实际上是一个对象，这个对象在循环中用来处理程序运行过程中出现的各种事件（比如说触摸事件、UI刷新事件、定时器事件、Selector事件），从而保持程序的持续运行；而且在没有事件处理的      时候，会进入睡眠模式，从而节省CPU资源，提高程序性能。
    
    // 二、RunLoop 和 线程
    // RunLoop和线程是息息相关的，我们知道线程的作用是用来执行特定的一个或多个任务，但是在默认情况下，线程执行完之后就会退出，就不能再执行任务了。这时我们就需要采用一种方式来让线程能够处理任务，并不退出。所以，我们就有了RunLoop。
    
    //       一条线程对应一个RunLoop对象，每条线程都有唯一一个与之对应的RunLoop对象。
    //       我们只能在当前线程中操作当前线程的RunLoop，而不能去操作其他线程的RunLoop。
    //       RunLoop对象在第一次获取RunLoop时创建，销毁则是在线程结束的时候。
    //       主线程的RunLoop对象系统自动帮助我们创建好了(原理如下)，而子线程的RunLoop对象需要我们主动创建。
    
    // 三、RunLoop相关类
    // 下面我们来了解一下Core Foundation框架下关于RunLoop的5个类，只有弄懂这几个类的含义，我们才能深入了解RunLoop运行机制。
    
    // CFRunLoopRef：代表RunLoop的对象
    // CFRunLoopModeRef：RunLoop的运行模式
    // CFRunLoopSourceRef：就是RunLoop模型图中提到的输入源/事件源
    // CFRunLoopTimerRef：就是RunLoop模型图中提到的定时源
    // CFRunLoopObserverRef：观察者，能够监听RunLoop的状态改变
    
    // 1、CFRunLoopRef    CFRunLoopRef就是Core Foundation框架下RunLoop对象类。我们可通过以下方式来获取RunLoop对象：
    //      Core Foundation 下
            CFRunLoopGetCurrent(); // 获得当前线程的RunLoop对象
            CFRunLoopGetMain(); // 获得主线程的RunLoop对象
    
    //      在Foundation 框架下
            [NSRunLoop currentRunLoop];  // 获得当前线程的RunLoop对象
            [NSRunLoop mainRunLoop]; // 获得主线程的RunLoop对象
    
    // 2、CFRunLoopModeRef  运行模式   其中kCFRunLoopDefaultMode、UITrackingRunLoopMode、kCFRunLoopCommonModes是我们开发中需要用到的模式
    //      kCFRunLoopDefaultMode：App的默认运行模式，通常主线程是在这个运行模式下运行
    //      UITrackingRunLoopMode：跟踪用户交互事件（用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他Mode影响）
    //      UIInitializationRunLoopMode：在刚启动App时第进入的第一个 Mode，启动完成后就不再使用
    //      GSEventReceiveRunLoopMode：接受系统内部事件，通常用不到
    //      kCFRunLoopCommonModes：伪模式，不是一种真正的运行模式 而是一种标记模式，意思就是可以在打上Common Modes标记的模式下运行。
    
    // 3、 CFRunLoopTimerRef   理解为基于时间的触发器，基本上就是NSTimer
            [self RunLoop_timer];
    // 4、CFRunLoopSourceRef 事件源
    
    // 5、CFRunLoopObserverRef 观察者，用来监听RunLoop的状态改变
    //      CFRunLoopObserverRef可以监听的状态改变有以下几种：
            typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
                kCFRunLoopEntry = (1UL << 0),               // 即将进入Loop：1
                kCFRunLoopBeforeTimers = (1UL << 1),        // 即将处理Timer：2
                kCFRunLoopBeforeSources = (1UL << 2),       // 即将处理Source：4
                kCFRunLoopBeforeWaiting = (1UL << 5),       // 即将进入休眠：32
                kCFRunLoopAfterWaiting = (1UL << 6),        // 即将从休眠中唤醒：64
                kCFRunLoopExit = (1UL << 7),                // 即将从Loop中退出：128
                kCFRunLoopAllActivities = 0x0FFFFFFFU       // 监听全部状态改变
            };
    [self RunLoop_obsver];
    
    // 四、Runloop 原理
    [self RunLoop_yuanli];
    
    // 五、Runloop 实战应用
    [self showDemo3];
    [self showDemo4];
}


// 运行下面的方法，这时候我们发现如果我们不对模拟器进行任何操作的话，定时器会稳定的每隔2秒调用run方法打印
// 但是当我们拖动Text View滚动时，我们发现：run方法不打印了，也就是说NSTimer不工作了。而当我们松开鼠标的时候，NSTimer就又开始正常工作了。

// 原因：当我们不做任何操作的时候，RunLoop处于NSDefaultRunLoopMode下。 而当我们拖动Text View的时候，RunLoop就结束NSDefaultRunLoopMode，切换到了UITrackingRunLoopMode模式下，这个模式下没有添加NSTimer，所以我们的NSTimer就不工作了。但当我们松开鼠标的时候，RunLoop就结束UITrackingRunLoopMode模式，又切换回NSDefaultRunLoopMode模式，所以NSTimer就又开始正常工作了。
// 解决办法：我们只要我们将NSTimer添加到当前RunLoop的kCFRunLoopCommonModes（Foundation框架下为NSRunLoopCommonModes）下，我们就可以让NSTimer在不做操作和拖动Text View两种情况下愉快的正常工作了。

- (void)RunLoop_timer {
    
    // 定义一个定时器，约定两秒之后调用self的run方法
    NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(run) userInfo:nil repeats:YES];
    
    // 将定时器添加到当前RunLoop的NSDefaultRunLoopMode下
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

    // 解决方法：
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    
    // NSTimer中的scheduledTimerWithTimeInterval方法和RunLoop的关系   下面的方法 NSTimer会自动被加入到了RunLoop的NSDefaultRunLoopMode模式下
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(run) userInfo:nil repeats:YES];

}

- (void)run
{
    NSLog(@"---run");
}

#pragma mark- runloop 观察者
- (void)RunLoop_obsver {
    // 创建观察者
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        NSLog(@"监听到RunLoop发生改变---%zd",activity);
    });
    
    // 添加观察者到当前RunLoop中
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    
    // 释放observer，最后添加完需要释放掉
    CFRelease(observer);
    
}


#pragma mark- 原理 实现过程
- (void)RunLoop_yuanli {
    
    // 通知观察者RunLoop已经启动
    // 通知观察者即将要开始的定时器
    // 通知观察者任何即将启动的非基于端口的源
    // 启动任何准备好的非基于端口的源
    // 如果基于端口的源准备好并处于等待状态，立即启动；并进入步骤9
    // 通知观察者线程进入休眠状态
    // 将线程置于休眠知道任一下面的事件发生：
    //      某一事件到达基于端口的源
    //      定时器启动
    //      RunLoop设置的时间已经超时
    //      RunLoop被显示唤醒
    // 通知观察者线程将被唤醒
    // 处理未处理的事件
    //      如果用户定义的定时器启动，处理定时器事件并重启RunLoop。进入步骤2
    //      如果输入源启动，传递相应的消息
    //      如果RunLoop被显示唤醒而且时间还没超时，重启RunLoop。进入步骤2
    // 通知观察者RunLoop结束。
}

/**
 * 第三个例子：用来展示UIImageView的延迟显示
 */
- (void)showDemo3
{
    // 原因：   当界面中含有UITableView，而且每个UITableViewCell里边都有图片。这时候当我们滚动UITableView的时候，如果有一堆的图片需要显示，那么可能会出现卡顿的现象。
    // 解决办法：这时候，我们应该推迟图片的显示，也就是ImageView推迟显示图片
    
    // 1、 因为UITableView继承自UIScrollView，所以我们可以通过监听UIScrollView的滚动，实现UIScrollView相关delegate即可。
    // 2、 利用PerformSelector设置当前线程的RunLoop的运行模式  利用performSelector方法为UIImageView调用setImage:方法，并利用inModes将其设置为RunLoop下NSDefaultRunLoopMode运行模式
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView performSelector:@selector(setImage:) withObject:[UIImage imageNamed:@"tupian"] afterDelay:4.0 inModes:@[NSDefaultRunLoopMode]];
}

/**
 * 第四个例子：用来展示常驻内存的方式
 */
- (void)showDemo4
{
    // 问题： 我们在开发应用程序的过程中，如果后台操作特别频繁，经常会在子线程做一些耗时操作（下载文件、后台播放音乐等），我们最好能让这条线程永远常驻内存。
    
    // 解决办法：添加一条用于常驻内存的强引用的子线程，在该线程的RunLoop下添加一个Sources，开启RunLoop。
    
    // 1、在项目的ViewController.m中添加一条强引用的thread线程属性
    // 2、在viewDidLoad中创建线程self.thread，使线程启动并执行run1方法
    
    // 创建线程，并调用run1方法执行任务
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(run1) object:nil];
    [self.thread start];
    
    // 利用performSelector调用常驻线程self.thread的run2方法
    //    [self performSelector:@selector(run2) onThread:self.thread withObject:nil waitUntilDone:NO]; // 用来展示常驻内存的方式
}

- (void) run1
{
    // 这里写任务
    NSLog(@"----run1-----");
    
    // 添加下边两句代码，就可以开启RunLoop，之后self.thread就变成了常驻线程，可随时添加任务，并交于RunLoop处理
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
    
    // 测试是否开启了RunLoop，如果开启RunLoop，则来不了这里，因为RunLoop开启了循环。
    NSLog(@"未开启RunLoop");
}


@end
