//
//  MirrorMacro.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SpanType) {
    SpanTypeWeek,
    SpanTypeMonth,
    SpanTypeYear,
};

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kIs_iphone ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
#define kIs_iPhoneX kScreenWidth >=375.0f && kScreenHeight >=812.0f&& kIs_iphone
    
/*状态栏高度*/
#define kStatusBarHeight (CGFloat)(kIs_iPhoneX?(44.0):(20.0))
/*导航栏高度*/
#define kNavBarHeight (44)
/*TabBar高度*/
#define kTabBarHeight (CGFloat)(kIs_iPhoneX?(49.0 + 34.0):(49.0))
/*顶部安全区域远离高度*/
#define kTopBarSafeHeight (CGFloat)(kIs_iPhoneX?(44.0):(0))
 /*底部安全区域远离高度*/
#define kBottomSafeHeight (CGFloat)(kIs_iPhoneX?(34.0):(0))
/*iPhoneX的状态栏高度差值*/
#define kTopBarDifHeight (CGFloat)(kIs_iPhoneX?(24.0):(0))

// Font
// https://stackoverflow.com/questions/8090916/fonts-on-ios-device

// 侧边半屏ratio
#define kLeftSheetRatio (0.7)
// Max number of colors
#define kMaxColorNum (8)
// Max number of tasks
#define kMaxTaskNum (8)
// 最小记录时间
#define kMinSeconds (1)
// 最长记录时间
#define kMaxSeconds (NSIntegerMax)

// Settings Notifications
#define MirrorSwitchThemeNotification @"MirrorSwitchThemeNotification"
#define MirrorSwitchLanguageNotification @"MirrorSwitchLanguageNotification"
#define MirrorSwitchTimerModeNotification @"MirrorSwitchTimerModeNotification"
#define MirrorSwitchWeekStartsOnNotification @"MirrorSwitchWeekStartsOnNotification"
// Data Notifications (MirrorStorage统一来发)
#define MirrorTaskCreateNotification @"MirrorTaskCreateNotification"
#define MirrorTaskDeleteNotification @"MirrorTaskDeleteNotification"
#define MirrorTaskArchiveNotification @"MirrorTaskArchiveNotification"
#define MirrorTaskEditNotification @"MirrorTaskEditNotification"
#define MirrorTaskStartNotification @"MirrorTaskStartNotification"
#define MirrorTaskStopNotification @"MirrorTaskStopNotification"
#define MirrorPeriodDeleteNotification @"MirrorPeriodDeleteNotification"
#define MirrorPeriodEditNotification @"MirrorPeriodEditNotification"

@interface MirrorMacro : NSObject

@end

NS_ASSUME_NONNULL_END
