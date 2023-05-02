//
//  AppDelegate.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/24.
//

#import "AppDelegate.h"
#import "MirrorTabsManager.h"
#import "MirrorSettings.h"
#import "MirrorStorage.h"
#import "MirrorMacro.h"

@interface AppDelegate () <UITabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 由于删除了storyboard，所以需要自己手动创建UIWindow
    _window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    UITabBarController *tabbarController = [[MirrorTabsManager sharedInstance] mirrorTabController];
    //@protovol <UITabBarControllerDelegate>
    tabbarController.delegate = self;
    
    //init navigation controller with tabbar controller (nc needs a root view)
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tabbarController];
    [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navigationController.navigationBar.shadowImage = [UIImage new];
    
    _window.rootViewController = navigationController;
    [_window makeKeyAndVisible];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

- (void)applicationSignificantTimeChange:(UIApplication *)application
{
    // 用户当前的时区，和数据被执行零点切割的时区不一样了，需要修改所有时间数据
    NSInteger timeZoneGap = [MirrorSettings timeZoneGap:[NSTimeZone systemTimeZone].secondsFromGMT];
    if (timeZoneGap) {
        [MirrorStorage changeDataWithTimezoneGap:timeZoneGap];
    }
    // 发出一个重刷页面的通知（强制改时区可用、零点刷新也可用）
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorSignificantTimeChangeNotification object:nil userInfo:nil];
}


@end
