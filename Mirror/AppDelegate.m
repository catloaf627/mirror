//
//  AppDelegate.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/24.
//

#import "AppDelegate.h"

#import "TimeTrackerViewController.h"
#import "HistoryViewController.h"
#import "ProfileViewController.h"
@interface AppDelegate ()<UITabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 由于删除了storyboard，所以需要自己手动创建UIWindow
    _window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.rootViewController = [self mirrorRootVC];
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
