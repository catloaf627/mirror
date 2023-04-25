//
//  MirrorTimeText.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/25.
//

#import "MirrorTimeText.h"
#import "MirrorLanguage.h"
#import "MirrorSettings.h"

@implementation MirrorTimeText

//// 哪项没有省略哪项 16d,1h23m5s | 16天，1小时23分钟5秒 —> lasted后面的标记
//+ (NSString *)XdXhXmXs:(long)timeInterval
//{
//
//}
//// 只展示最大项 1.3 days/4.5 hours | 1.3天/4.5小时 —> 柱状图上面的标记
//+ (NSString *)XdXhXmXsWithOneMaxUnit:(long)timeInterval
//{
//
//}

// Thu, Apr 25, 2023 | 2023年4月23日，周日 -> 柱状图区间切换的标记（一天）
+ (NSString *)YYYYmmddWeekday:(NSDate *)date
{
    // setup
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:date];
    components.timeZone = [NSTimeZone systemTimeZone];
    // details
    long year = (long)components.year;
    long month = (long)components.month;
    long day = (long)components.day;
    long week = (long)components.weekday;
    
    NSString *weekstr = @"";
    if (week == 1) weekstr = [MirrorLanguage mirror_stringWithKey:@"sunday"];
    if (week == 2) weekstr = [MirrorLanguage mirror_stringWithKey:@"monday"];
    if (week == 3) weekstr = [MirrorLanguage mirror_stringWithKey:@"tuesday"];
    if (week == 4) weekstr = [MirrorLanguage mirror_stringWithKey:@"wednesday"];
    if (week == 5) weekstr = [MirrorLanguage mirror_stringWithKey:@"thursday"];
    if (week == 6) weekstr = [MirrorLanguage mirror_stringWithKey:@"friday"];
    if (week == 7) weekstr = [MirrorLanguage mirror_stringWithKey:@"saturday"];
    
    NSString *monthstr = @"";
    if (month == 1) monthstr = [MirrorLanguage mirror_stringWithKey:@"january"];
    if (month == 2) monthstr = [MirrorLanguage mirror_stringWithKey:@"february"];
    if (month == 3) monthstr = [MirrorLanguage mirror_stringWithKey:@"march"];
    if (month == 4) monthstr = [MirrorLanguage mirror_stringWithKey:@"april"];
    if (month == 5) monthstr = [MirrorLanguage mirror_stringWithKey:@"may"];
    if (month == 6) monthstr = [MirrorLanguage mirror_stringWithKey:@"june"];
    if (month == 7) monthstr = [MirrorLanguage mirror_stringWithKey:@"july"];
    if (month == 8) monthstr = [MirrorLanguage mirror_stringWithKey:@"august"];
    if (month == 9) monthstr = [MirrorLanguage mirror_stringWithKey:@"september"];
    if (month == 10) monthstr = [MirrorLanguage mirror_stringWithKey:@"october"];
    if (month == 11) monthstr = [MirrorLanguage mirror_stringWithKey:@"november"];
    if (month == 12) monthstr = [MirrorLanguage mirror_stringWithKey:@"december"];
    
    if ([MirrorSettings appliedChinese]) {
        return [NSString stringWithFormat: @"%ld年%@%ld日，%@", year, monthstr, day, weekstr]; // 2023年4月25日，周二
    } else {
        return [NSString stringWithFormat: @"%@, %@ %ld, %ld",weekstr,  monthstr, day, year]; // Thu, Apr 25, 2023
    }
}

// Apr 25, 2023 | 2023年4月23日 -> 柱状图区间切换的标记（区间）
+ (NSString *)YYYYmmdd:(NSDate *)date
{
    // setup
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    components.timeZone = [NSTimeZone systemTimeZone];
    // details
    long year = (long)components.year;
    long month = (long)components.month;
    long day = (long)components.day;
    
    NSString *monthstr = @"";
    if (month == 1) monthstr = [MirrorLanguage mirror_stringWithKey:@"january"];
    if (month == 2) monthstr = [MirrorLanguage mirror_stringWithKey:@"february"];
    if (month == 3) monthstr = [MirrorLanguage mirror_stringWithKey:@"march"];
    if (month == 4) monthstr = [MirrorLanguage mirror_stringWithKey:@"april"];
    if (month == 5) monthstr = [MirrorLanguage mirror_stringWithKey:@"may"];
    if (month == 6) monthstr = [MirrorLanguage mirror_stringWithKey:@"june"];
    if (month == 7) monthstr = [MirrorLanguage mirror_stringWithKey:@"july"];
    if (month == 8) monthstr = [MirrorLanguage mirror_stringWithKey:@"august"];
    if (month == 9) monthstr = [MirrorLanguage mirror_stringWithKey:@"september"];
    if (month == 10) monthstr = [MirrorLanguage mirror_stringWithKey:@"october"];
    if (month == 11) monthstr = [MirrorLanguage mirror_stringWithKey:@"november"];
    if (month == 12) monthstr = [MirrorLanguage mirror_stringWithKey:@"december"];
    
    if ([MirrorSettings appliedChinese]) {
        return [NSString stringWithFormat: @"%ld年%@%ld日", year, monthstr, day]; // 2023年4月25日
    } else {
        return [NSString stringWithFormat: @"%@ %ld, %ld",  monthstr, day, year]; // Apr 25, 2023
    }
}



@end
