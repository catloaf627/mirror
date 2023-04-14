//
//  MirrorSettings.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, UserPreferredHistogramType) {
    UserPreferredHistogramTypeToday, // 库里没有这个taskname，taskname合格
    UserPreferredHistogramTypeThisWeek,
    UserPreferredHistogramTypeThisMonth,
    UserPreferredHistogramTypeThisYear,
};

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

// Show which histogram
+ (UserPreferredHistogramType)userPreferredHistogramType;
+ (void)userSetPreferredHistogramType:(UserPreferredHistogramType)type;

@end

NS_ASSUME_NONNULL_END
