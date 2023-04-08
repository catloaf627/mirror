//
//  MirrorMacro.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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

// Max number of colors
#define kMaxColorNum (8)
// Max number of tasks
#define kMaxTaskNum (8)

// Settings Notifications
#define MirrorSwitchThemeNotification @"MirrorSwitchThemeNotification"
#define MirrorSwitchLanguageNotification @"MirrorSwitchLanguageNotification"
#define MirrorSwitchImmersiveModeNotification @"MirrorSwitchImmersiveModeNotification"

// Data Notifications (MirrorStorage统一来发)
#define MirrorTaskCreateNotification @"MirrorTaskCreateNotification" // 没用
#define MirrorTaskDeleteNotification @"MirrorTaskDeleteNotification" // 未来可能有用（比如在其他页面删除了一个正在计时的task，这时候主页面是要更新的）
#define MirrorTaskArchiveNotification @"MirrorTaskArchiveNotification" // 弹"已归档"弹窗
#define MirrorTaskStartNotification @"MirrorTaskStartNotification" // 没用
#define MirrorTaskStopNotification @"MirrorTaskStopNotification" // 弹"已保存"弹窗
// Data Notification (有Timer的业务部分自己发)
#define MirrorTaskTimeLimitNotification @"MirrorTaskTimeLimitNotification" // 弹"超时"弹窗
// Data Notification （只要发现数据出错就可以发）
#define MirrorTaskErrorNotification @"MirrorTaskErrorNotification" // 弹"出错"弹窗

@interface MirrorMacro : NSObject

@end

NS_ASSUME_NONNULL_END
