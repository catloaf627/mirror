//
//  MirrorSettings.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/10.
//

#import "MirrorSettings.h"

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

+ (BOOL)appliedPieChartData
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredPiechartData"];
}

+ (void)switchChartTypeData
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredPiechartData"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MirrorUserPreferredPiechartData"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MirrorUserPreferredPiechartData"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorSwitchChartTypeDataNotification object:nil];
}

+ (BOOL)appliedPieChartRecord
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredPiechartRecord"];
}

+ (void)switchChartTypeRecord
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredPiechartRecord"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MirrorUserPreferredPiechartRecord"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MirrorUserPreferredPiechartRecord"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorSwitchChartTypeRecordNotification object:nil];
}

+ (NSInteger)timeZoneGap:(NSInteger)newSecondsFromGMT
{
    // 如果之前没存过本地timezone，存本地timezone，并将时差返回为0
    if (![[[NSUserDefaults standardUserDefaults] dictionaryRepresentation].allKeys containsObject:@"MirrorUserTimeZone"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:newSecondsFromGMT forKey:@"MirrorUserTimeZone"];
        return 0;
    }
    // 如果之前存过本地timezone，返回时差本次检测出来的时差
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

// 按照时间长短更新颜色深浅
+ (BOOL)appliedHeatmap
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredHeatmap"];
}

+ (void)switchHeatmap
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredHeatmap"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MirrorUserPreferredHeatmap"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MirrorUserPreferredHeatmap"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorSwitchShowShadeNotification object:nil];
}

+ (NSInteger)preferredHeatmapColor
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"MirrorUserPreferredHeatmapColor"];
}

+ (void)changePreferredHeatmapColor:(NSInteger)color
{
    [[NSUserDefaults standardUserDefaults] setInteger:color forKey:@"MirrorUserPreferredHeatmapColor"];
}

// Show original index

+ (BOOL)appliedShowIndex
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredShowIndex"];
}
+ (void)switchShowIndex
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredShowIndex"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MirrorUserPreferredShowIndex"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MirrorUserPreferredShowIndex"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorSwitchShowIndexNotification object:nil];
}

+ (NSString *)userMotto
{
    NSString *motto = [[NSUserDefaults standardUserDefaults] stringForKey:@"MirrorUserMotto"];
    if (motto==nil) {
        return @"Mirror, mirror on the wall, who is the fairest of them all?";
    } else {
        return motto;
    }
}

+ (void)saveUserMotto:(NSString *)motto
{
    [[NSUserDefaults standardUserDefaults] setObject:motto forKey:@"MirrorUserMotto"];
}

+ (SpanType)spanType
{
    NSNumber *spanType = [[NSUserDefaults standardUserDefaults] objectForKey:@"MirrorUserPreferredSpanType"];
    if (spanType==nil) {
        [[NSUserDefaults standardUserDefaults] setInteger:SpanTypeWeek forKey:@"MirrorUserPreferredSpanType"];
        return SpanTypeWeek; // 如果用户没有点过，默认展示week
    } else {
        return [spanType integerValue];
    }
}

+ (void)changeSpanType:(SpanType)spanType
{
    [[NSUserDefaults standardUserDefaults] setInteger:spanType forKey:@"MirrorUserPreferredSpanType"];
}

@end
