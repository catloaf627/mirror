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
#import "MirrorLanguage.h"

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
    tabbarController.tabBar.barTintColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    tabbarController.tabBar.backgroundImage = [UIImage new];
    tabbarController.tabBar.shadowImage = [UIImage new];
    
    [TabbarControllerGenerater updateMeTabItemWithTabController:tabbarController];
    [TabbarControllerGenerater updateTimeTabItemWithTabController:tabbarController];
    [TabbarControllerGenerater updateHistoryTabItemWithTabController:tabbarController];
    
    return tabbarController;
}

+ (void)updateMeTabItemWithTabController:(UITabBarController *)tabbarController
{
    MirrorLanguageType language = MirrorLanguageTypeChinese; //gizmo 暂时写死
    [TabbarControllerGenerater tabbar:tabbarController.tabBar index:0 tabbarItemWithTitle:[MirrorLanguage stringWithKey:@"me" Language:language] imageName:@"person" selectedImageName:@"person.fill"];
}

+ (void)updateTimeTabItemWithTabController:(UITabBarController *)tabbarController
{
    MirrorLanguageType language = MirrorLanguageTypeChinese; //gizmo 暂时写死
    [TabbarControllerGenerater tabbar:tabbarController.tabBar index:1 tabbarItemWithTitle:[MirrorLanguage stringWithKey:@"start" Language:language] imageName:@"clock" selectedImageName:@"clock.fill"];
}

+ (void)updateHistoryTabItemWithTabController:(UITabBarController *)tabbarController
{
    MirrorLanguageType language = MirrorLanguageTypeChinese; //gizmo 暂时写死
    [TabbarControllerGenerater tabbar:tabbarController.tabBar index:2 tabbarItemWithTitle:[MirrorLanguage stringWithKey:@"data" Language:language] imageName:@"chart.bar" selectedImageName:@"chart.bar.fill"];
}

+ (UITabBarItem *)tabbar:(UITabBar *)tabbar index:(NSInteger)index tabbarItemWithTitle:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName
{
    UITabBarItem *item = [tabbar.items objectAtIndex:index];
    [item setTitle:title];
    // 默认图片
    UIImage *image = [[UIImage systemImageNamed:imageName] imageWithTintColor:[UIColor mirrorColorNamed:MirrorColorTypeTabbarIconText]];
    // 选中图片
    UIImage *selectedImage = [[UIImage systemImageNamed:selectedImageName] imageWithTintColor:[UIColor mirrorColorNamed:MirrorColorTypeTabbarIconTextHightlight]];
    // 设置图片
    [item setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:image];
    
    // 默认文字
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor mirrorColorNamed:MirrorColorTypeTabbarIconText]} forState:UIControlStateNormal];
    // 选中文字
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor mirrorColorNamed:MirrorColorTypeTabbarIconTextHightlight]} forState:UIControlStateSelected];

    [item imageInsets];
    return item;
}

@end
