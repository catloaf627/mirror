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

// Week starts on
+ (BOOL)appliedWeekStarsOnMonday;
+ (void)switchWeekStartsOn;

// Pie chart
+ (BOOL)appliedPieChart;
+ (void)switchChartType;

// Timezone
+ (NSInteger)timeZoneGap:(NSInteger)newSecondsFromGMT;

// 按照时间长短更新颜色深浅
+ (BOOL)appliedShowShade;
+ (void)switchShowShade;

+ (NSInteger)preferredShadeColor;
+ (void)changePreferredShadeColor:(NSInteger)color;

@end

NS_ASSUME_NONNULL_END
