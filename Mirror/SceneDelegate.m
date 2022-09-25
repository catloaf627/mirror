//
//  SceneDelegate.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/24.
//

#import "SceneDelegate.h"

#import "TimeTrackerViewController.h"
#import "HistoryViewController.h"
#import "ProfileViewController.h"

@interface SceneDelegate ()<UITabBarControllerDelegate>

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // 由于删除了storyboard，所以需要自己手动创建UIWindow
    // 类似于iPad可以分屏，所以有多个scene
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    _window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.rootViewController = [self mirrorRootVC];
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

- (UINavigationController *)mirrorRootVC
{
    TimeTrackerViewController *timeTrackerVC = [[TimeTrackerViewController alloc]init];
    HistoryViewController *historyVC = [[HistoryViewController alloc]init];
    ProfileViewController *profileVC = [[ProfileViewController alloc]init];
    
    //create a tabbar controller
    UITabBarController *tabbarController  = [[UITabBarController alloc] init];
    
    //add 4 view controllers to tabbar controller
    [tabbarController setViewControllers:@[profileVC, timeTrackerVC, historyVC]];
    tabbarController.selectedIndex = 1;
    tabbarController.tabBar.barTintColor = [UIColor whiteColor];
    tabbarController.tabBar.backgroundImage = [UIImage new];
    tabbarController.tabBar.shadowImage = [UIImage new];
    [tabbarController.tabBar setSelectedImageTintColor:[UIColor blackColor]];
    
    
    UITabBarItem *profileItem = [tabbarController.tabBar.items objectAtIndex:0];
    [profileItem setTitle:@"Me"];
    [profileItem setFinishedSelectedImage:[UIImage systemImageNamed:@"person.fill"] withFinishedUnselectedImage:[UIImage systemImageNamed:@"person"]];
    [profileItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateSelected];
    [profileItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
    [profileItem imageInsets];
    
    UITabBarItem *timeTrackerItem = [tabbarController.tabBar.items objectAtIndex:1];
    [timeTrackerItem setTitle:@"Start"];
    [timeTrackerItem setFinishedSelectedImage:[UIImage systemImageNamed:@"clock.fill"] withFinishedUnselectedImage:[UIImage systemImageNamed:@"clock"]];
    [timeTrackerItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateSelected];
    [timeTrackerItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
    [timeTrackerItem imageInsets];
    

    UITabBarItem *historyItem = [tabbarController.tabBar.items objectAtIndex:2];
    [historyItem setTitle:@"Data"];
    [historyItem setFinishedSelectedImage:[UIImage systemImageNamed:@"chart.bar.fill"] withFinishedUnselectedImage:[UIImage systemImageNamed:@"chart.bar"]];
    [historyItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateSelected];
    [historyItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
    [historyItem imageInsets];
    
    
    //@protovol <UITabBarControllerDelegate>
    tabbarController.delegate = self;
    
    //init navigation controller with tabbar controller (nc needs a root view)
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tabbarController];
    
    [navigationController.navigationBar removeFromSuperview];
    
    return navigationController;
}


@end
