//
//  MirrorTabsManager.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/25.
//

#import "MirrorTabsManager.h"

#import "TimeTrackerViewController.h"
#import "DataViewController.h"
#import "ProfileViewController.h"

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
        TimeTrackerViewController *timeTrackerVC = [[TimeTrackerViewController alloc]init];
        DataViewController *dataVC = [[DataViewController alloc]init];
        ProfileViewController *profileVC = [[ProfileViewController alloc]init];
        
        //create a tabbar controller
        _mirrorTabVC  = [[UITabBarController alloc] init];
        
        //add 4 view controllers to tabbar controller
        [_mirrorTabVC setViewControllers:@[profileVC, timeTrackerVC, dataVC]];
        _mirrorTabVC.selectedIndex = 1;
        _mirrorTabVC.tabBar.barTintColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
        _mirrorTabVC.tabBar.backgroundImage = [UIImage new];
        _mirrorTabVC.tabBar.shadowImage = [UIImage new];
        
        [self updateMeTabItemWithTabController:_mirrorTabVC];
        [self updateTimeTabItemWithTabController:_mirrorTabVC];
        [self updateHistoryTabItemWithTabController:_mirrorTabVC];
    }
    return _mirrorTabVC;
}

- (void)updateMeTabItemWithTabController:(UITabBarController *)tabbarController
{
    [self tabbar:tabbarController.tabBar index:0 tabbarItemWithTitle:[MirrorLanguage mirror_stringWithKey:@"me"] imageName:@"person" selectedImageName:@"person.fill"];
}

- (void)updateTimeTabItemWithTabController:(UITabBarController *)tabbarController
{
    [self tabbar:tabbarController.tabBar index:1 tabbarItemWithTitle:[MirrorLanguage mirror_stringWithKey:@"start"] imageName:@"clock" selectedImageName:@"clock.fill"];
}

- (void)updateHistoryTabItemWithTabController:(UITabBarController *)tabbarController
{
    [self tabbar:tabbarController.tabBar index:2 tabbarItemWithTitle:[MirrorLanguage mirror_stringWithKey:@"data"] imageName:@"chart.bar" selectedImageName:@"chart.bar.fill"];
}

- (UITabBarItem *)tabbar:(UITabBar *)tabbar index:(NSInteger)index tabbarItemWithTitle:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName
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
