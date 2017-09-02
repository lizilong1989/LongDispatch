//
//  AppDelegate.m
//  DispatchDemo
//
//  Created by EaseMob on 2017/9/1.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import "AppDelegate.h"

#import "LongDispatch.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    LongDispatch *dispatch = [LongDispatch new];
    for (int i = 0; i < 20; i++) {
        NSString *taskId = [dispatch addTask:^{
            sleep(3);
            NSLog(@"%d",i);
        }];
        [dispatch cancelTask:taskId];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [dispatch cancelAllTask];
//        [dispatch addTask:^{
//            sleep(3);
//            NSLog(@"%d",20);
//        }];
    });

    

//    dispatch_block_t block = dispatch_block_create(DISPATCH_BLOCK_BARRIER, ^{
//        sleep(10);
//        NSLog(@"%d",100);
//    });
//    
//    dispatch_async(dispatch_get_global_queue(0, 0), block);
//    dispatch_block_cancel(block);
//    
////    [dispatch addTask:block];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////        [dispatch cancelAllTask];
//        dispatch_block_cancel(block);
//    });

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end