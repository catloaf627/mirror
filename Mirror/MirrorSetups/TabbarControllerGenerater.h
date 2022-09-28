//
//  TabbarControllerGenerater.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TabbarControllerGenerater : NSObject

+ (UITabBarController *)mirrorTabVC;
+ (void)updateMeTabItemWithTabController:(UITabBarController *)tabbarController;
+ (void)updateTimeTabItemWithTabController:(UITabBarController *)tabbarController;
+ (void)updateHistoryTabItemWithTabController:(UITabBarController *)tabbarController;

@end

NS_ASSUME_NONNULL_END
