//
//  MirrorTabsManager.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/25.
//

#import "MirrorTabsManager.h"

#import "TimeViewController.h"
#import "TodayViewController.h"
#import "HistoryViewController.h"

#import "UIColor+MirrorColor.h"
#import "MirrorLanguage.h"

@interface MirrorTabsManager ()

@property (nonatomic, strong) UITabBarController *mirrorTabVC;

@end

@implementation MirrorTabsManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static MirrorTabsManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[MirrorTabsManager alloc]init];
    });
    return instance;
}

- (UITabBarController *)mirrorTabController
{
    if (!_mirrorTabVC) {
        TimeViewController *timeTrackerVC = [[TimeViewController alloc]init];
        TodayViewController *todayVC = [[TodayViewController alloc]init];
        HistoryViewController *historyVC = [[HistoryViewController alloc] init];
        //create a tabbar controller
        _mirrorTabVC  = [[UITabBarController alloc] init];
        
        //add 4 view controllers to tabbar controller
        [_mirrorTabVC setViewControllers:@[timeTrackerVC, todayVC, historyVC]];
        _mirrorTabVC.selectedIndex = 0;
        _mirrorTabVC.tabBar.barTintColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
        _mirrorTabVC.tabBar.backgroundImage = [UIImage new];
        _mirrorTabVC.tabBar.shadowImage = [UIImage new];

        [self updateTimeTabItemWithTabController:_mirrorTabVC];
        [self updateDataTabItemWithTabController:_mirrorTabVC];
        [self updateHistoryTabItemWithTabController:_mirrorTabVC];
    }
    return _mirrorTabVC;
}

- (void)updateTimeTabItemWithTabController:(UITabBarController *)tabbarController
{
    [self updateTabbar:tabbarController.tabBar index:0 tabbarItemWithTitle:[MirrorLanguage mirror_stringWithKey:@"start"] imageName:@"alarm" selectedImageName:@"alarm.fill"];
}

- (void)updateDataTabItemWithTabController:(UITabBarController *)tabbarController
{
    [self updateTabbar:tabbarController.tabBar index:1 tabbarItemWithTitle:[MirrorLanguage mirror_stringWithKey:@"today"] imageName:@"chart.pie" selectedImageName:@"chart.pie.fill"];
}

- (void)updateHistoryTabItemWithTabController:(UITabBarController *)tabbarController
{
    [self updateTabbar:tabbarController.tabBar index:2 tabbarItemWithTitle:[MirrorLanguage mirror_stringWithKey:@"data"] imageName:@"chart.bar" selectedImageName:@"chart.bar.fill"];
}

- (void)updateTabbar:(UITabBar *)tabbar index:(NSInteger)index tabbarItemWithTitle:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName
{
    // 取出baritem
    UITabBarItem *item = [tabbar.items objectAtIndex:index];
    // 默认图片
    UIImage *image = [[UIImage systemImageNamed:imageName] imageWithTintColor:[UIColor mirrorColorNamed:MirrorColorTypeTabbarIconText]];
    UIImage *imageWithRightColor = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]; //这一行的作用是让image使用image本身的颜色，而不是系统颜色
    // 选中图片
    UIImage *selectedImage = [[UIImage systemImageNamed:selectedImageName] imageWithTintColor:[UIColor mirrorColorNamed:MirrorColorTypeTabbarIconTextHightlight]];
    UIImage *selectedImageWithRightColor = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];//这一行的作用是让image使用image本身的颜色，而不是系统颜色
    // 设置图片
    item = [item initWithTitle:title image:imageWithRightColor selectedImage:selectedImageWithRightColor];
    // 默认文字
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor mirrorColorNamed:MirrorColorTypeTabbarIconText]} forState:UIControlStateNormal];
    // 选中文字
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor mirrorColorNamed:MirrorColorTypeTabbarIconTextHightlight]} forState:UIControlStateSelected];

    [item imageInsets];
}

@end
