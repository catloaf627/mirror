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

// 1h 23m | 1时23分 —> lasted后面的标记
+ (NSString *)XdXhXmXsShortWithstart:(long)start end:(long)end
{
    long timeInterval = end - start;
    NSInteger numOfHours = timeInterval / 3600;
    NSInteger numOfMins = (timeInterval % 3600) / 60;
    NSInteger numOfSeconds = (timeInterval % 3600) % 60;
    NSString *res = @"";
    if (numOfHours > 0) {
        NSString *str = [MirrorLanguage mirror_stringWithKey:@"h" with1Placeholder:[@(numOfHours) stringValue]];
        res = [res stringByAppendingString:str];
    }
    if (numOfMins > 0) {
        NSString *str = [MirrorLanguage mirror_stringWithKey:@"m" with1Placeholder:[@(numOfMins) stringValue]];
        res = [res stringByAppendingString:str];
    }
    if (numOfSeconds > 0) {
        NSString *str = [MirrorLanguage mirror_stringWithKey:@"s" with1Placeholder:[@(numOfSeconds) stringValue]];
        res = [res stringByAppendingString:str];
    }
    return res;
}

// 1h 23m | 1时23分 —> 柱状图上的标记
+ (NSString *)XdXhXmXsShort:(long)timeInterval
{
    NSInteger numOfHours = timeInterval / 3600;
    NSInteger numOfMins = (timeInterval % 3600) / 60;
    NSInteger numOfSeconds = (timeInterval % 3600) % 60;
    NSString *res = @"";
    if (numOfHours > 0) {
        NSString *str = [MirrorLanguage mirror_stringWithKey:@"h" with1Placeholder:[@(numOfHours) stringValue]];
        res = [res stringByAppendingString:str];
    }
    if (numOfMins > 0) {
        NSString *str = [MirrorLanguage mirror_stringWithKey:@"m" with1Placeholder:[@(numOfMins) stringValue]];
        res = [res stringByAppendingString:str];
    }
    if (numOfSeconds > 0) {
        NSString *str = [MirrorLanguage mirror_stringWithKey:@"s" with1Placeholder:[@(numOfSeconds) stringValue]];
        res = [res stringByAppendingString:str];
    }
    return res;
}

// 1hour 23 mins | 1小时23分钟 —> total后面的标记
+ (NSString *)XdXhXmXsFull:(long)timeInterval
{
    NSInteger numOfHours = timeInterval / 3600;
    NSInteger numOfMins = (timeInterval % 3600) / 60;
    NSInteger numOfSeconds = (timeInterval % 3600) % 60;
    NSString *res = @"";
    if (numOfHours > 0) {
        NSString *str = @"";
        if (numOfHours == 1) {
            str = [MirrorLanguage mirror_stringWithKey:@"hour" with1Placeholder:[@(numOfHours) stringValue]];
        } else {
            str = [MirrorLanguage mirror_stringWithKey:@"hours" with1Placeholder:[@(numOfHours) stringValue]];
        }
        res = [res stringByAppendingString:str];
    }
    if (numOfMins > 0) {
        NSString *str = @"";
        if (numOfMins == 1) {
            str = [MirrorLanguage mirror_stringWithKey:@"min" with1Placeholder:[@(numOfMins) stringValue]];
        } else {
            str = [MirrorLanguage mirror_stringWithKey:@"mins" with1Placeholder:[@(numOfMins) stringValue]];
        }
        res = [res stringByAppendingString:str];
    }
    if (numOfSeconds > 0) {
        NSString *str = @"";
        if (numOfMins == 1) {
            str = [MirrorLanguage mirror_stringWithKey:@"second" with1Placeholder:[@(numOfSeconds) stringValue]];
        } else {
            str = [MirrorLanguage mirror_stringWithKey:@"seconds" with1Placeholder:[@(numOfSeconds) stringValue]];
        }
        res = [res stringByAppendingString:str];
    }
    return res;
}

// Thu, Apr 25, 2023 | 2023年4月23日，周日 -> 所有历史记录的日期标记
+ (NSString *)YYYYmmddWeekdayWithStart:(long)start
{
    // setup
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:[NSDate dateWithTimeIntervalSince1970:start]];
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

// Thu, Apr 25, 2023 | 2023年4月23日，周日 -> 柱状图区间切换的标记（一天）、Today下方的日期标记
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
