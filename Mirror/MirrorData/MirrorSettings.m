//
//  MirrorSettings.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/10.
//

#import "MirrorSettings.h"
#import "MirrorMacro.h"

@implementation MirrorSettings

+ (BOOL)appliedDarkMode
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredDarkMode"];
}

+ (void)switchTheme
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredDarkMode"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MirrorUserPreferredDarkMode"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MirrorUserPreferredDarkMode"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorSwitchThemeNotification object:nil];
}

+ (BOOL)appliedChinese
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredChinese"];
}

+ (void)switchLanguage
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredChinese"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MirrorUserPreferredChinese"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MirrorUserPreferredChinese"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorSwitchLanguageNotification object:nil];
}

+ (BOOL)appliedWeekStarsOnMonday
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredWeekStartsOnMonday"];
}

+ (void)switchWeekStartsOn
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredWeekStartsOnMonday"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MirrorUserPreferredWeekStartsOnMonday"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MirrorUserPreferredWeekStartsOnMonday"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorSwitchWeekStartsOnNotification object:nil];
}

+ (BOOL)appliedPieChart
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredPiechart"];
}

+ (void)switchChartType
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredPiechart"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MirrorUserPreferredPiechart"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MirrorUserPreferredPiechart"];
    }
    // 不需要通知，修改页面就是展示页面。
}

+ (NSInteger)timeZoneGap:(NSInteger)newSecondsFromGMT
{
    NSInteger oldSecondsFromGMT = [[NSUserDefaults standardUserDefaults] integerForKey:@"MirrorUserTimeZone"];
    [[NSUserDefaults standardUserDefaults] setInteger:newSecondsFromGMT forKey:@"MirrorUserTimeZone"];
    return oldSecondsFromGMT - newSecondsFromGMT;
    /*
     Standard     0h                         2023年5月2日13时                 标准时间
     Bejing      +8h(oldSecondsFromGMT)      2023年5月2日21时           （之前数字被切割的标准）
     New York    -4h                         2023年5月2日9时       想要展示为2023年5月2日21时，数据库数据需要+12
     London      +1h                         2023年5月2日14时      想要展示为2023年5月2日21时，数据库数据需要+7
     Tokyo       +9h                         2023年5月2日22时      想要展示为2023年5月2日21时，数据库数据需要-1
     */
}


@end
