//
//  SceneDelegate.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/24.
//

#import "SceneDelegate.h"
#import "MirrorTabsManager.h"
#import "UIColor+MirrorColor.h"
@interface SceneDelegate ()<UITabBarControllerDelegate>

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // 由于删除了storyboard，所以需要自己手动创建UIWindow
    // 类似于iPad可以分屏，所以有多个scene
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    _window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // UITabBarControllerDelegate
    UITabBarController *tabbarController = [[MirrorTabsManager sharedInstance] mirrorTabController];
    tabbarController.delegate = self;
    
    //init navigation controller with tabbar controller (nc needs a root view)
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tabbarController];
    
    // 设置navibar颜色（苹果好像自动会把navibar上比较深，接近纯黑色的颜色变成统一的深灰色）
    [[UINavigationBar appearance] setBarTintColor:[UIColor mirrorColorNamed:MirrorColorTypeBackground]];
    _window.rootViewController = navigationController;
    [_window makeKeyAndVisible];
    _window.windowScene = windowScene;
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}


@end
