//
//  TabbarControllerGenerater.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/25.
//

#import "TabbarControllerGenerater.h"

#import "TimeTrackerViewController.h"
#import "HistoryViewController.h"
#import "ProfileViewController.h"

#import "UIColor+MirrorColor.h"

@implementation TabbarControllerGenerater

+ (UITabBarController *)mirrorTabVC
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
    
    [TabbarControllerGenerater tabbar:tabbarController.tabBar index:0 tabbarItemWithTitle:@"Me" imageName:@"person" selectedImageName:@"person.fill"];
    
    [TabbarControllerGenerater tabbar:tabbarController.tabBar index:1 tabbarItemWithTitle:@"Start" imageName:@"clock" selectedImageName:@"clock.fill"];
    
    [TabbarControllerGenerater tabbar:tabbarController.tabBar index:2 tabbarItemWithTitle:@"Data" imageName:@"chart.bar" selectedImageName:@"chart.bar.fill"];
    
    return tabbarController;
}

+ (UITabBarItem *)tabbar:(UITabBar *)tabbar index:(NSInteger)index tabbarItemWithTitle:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName
{
    UITabBarItem *item = [tabbar.items objectAtIndex:index];
    [item setTitle:title];
    // 默认图片
    UIImage *image = [[UIImage systemImageNamed:imageName] imageWithTintColor:[UIColor mirrorColorNamed:MirrorColorTypeIconText]];
    // 选中图片
    UIImage *selectedImage = [[UIImage systemImageNamed:selectedImageName] imageWithTintColor:[UIColor mirrorColorNamed:MirrorColorTypeIconTextHightlight]];
    // 设置图片
    [item setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:image];
    
    // 默认文字
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor mirrorColorNamed:MirrorColorTypeIconText]} forState:UIControlStateNormal];
    // 选中文字
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor mirrorColorNamed:MirrorColorTypeIconTextHightlight]} forState:UIControlStateSelected];

    [item imageInsets];
    return item;
}

@end
