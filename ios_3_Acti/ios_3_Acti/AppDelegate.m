//
//  AppDelegate.m
//  ios_3_Acti
//
//  Created by admin1 on 2017/7/24.
//  Copyright © 2017年 Education. All rights reserved.
//

#import "AppDelegate.h"
#import <ECSlidingViewController/ECSlidingViewController.h>//门框结构

@interface AppDelegate ()
//初始化一个实例。获得门框
@property (strong, nonatomic) ECSlidingViewController *slidingVC;

@end

@implementation AppDelegate

//整个app第一个会执行的逻辑方法
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //初始化窗口（不用故事版设置箭头的时候，系统不会默认设置窗口，需手动设置）
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UINavigationController *navi = [Utilities getStoryboardInstance:@"Main" byIdentity:@"HomeNavi"];
    //将窗口可视化
    [_window makeKeyAndVisible];
    //创建门框(初始化的同时顺便设置好门框最外层的那扇门。也就是用户首先会看到的正中间的页面)(1.故事版名字2.视图控制器的名字)
    _slidingVC = [[ECSlidingViewController alloc] initWithTopViewController:navi];
    //放好左边那扇门(1.故事版名字2.视图控制器的名字)
    _slidingVC.underLeftViewController = [Utilities getStoryboardInstance:@"Member" byIdentity:@"Left"];
    //设置手势（表示让中间的门能够对拖拽与触摸响应）ECSlidingViewControllerAnchoredGestureTapping(触摸),ECSlidingViewControllerAnchoredGesturePanning(拖拽)
    _slidingVC.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
    //把上面配置好的手势添加到中间那扇门
    [navi.view addGestureRecognizer:_slidingVC.panGesture];
    
    //设置侧滑动画的执行时间
    _slidingVC.defaultTransitionDuration = 0.25; //(单位是秒)
    //设置滑动的幅度（中间那扇门打开的宽度）
    _slidingVC.anchorRightPeekAmount = UI_SCREEN_W / 6;
    
    //设置APP入口
    _window.rootViewController = _slidingVC;
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
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"ios_3_Acti"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
