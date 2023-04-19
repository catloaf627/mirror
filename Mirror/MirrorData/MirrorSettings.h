//
//  MirrorSettings.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MirrorSettings : NSObject

// Theme
+ (BOOL)appliedDarkMode;
+ (void)switchTheme;

// Language
+ (BOOL)appliedChinese;
+ (void)switchLanguage;

// Timer mode
+ (BOOL)appliedImmersiveMode;
+ (void)switchTimerMode;

// Week starts on
+ (BOOL)appliedWeekStarsOnMonday;
+ (void)switchWeekStartsOn;

@end

NS_ASSUME_NONNULL_END
