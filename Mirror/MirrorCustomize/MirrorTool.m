//
//  MirrorTool.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import "MirrorTool.h"

@implementation MirrorTool

+ (NSString *)timeFromDate:(NSDate *)date printTimeStamp:(BOOL)printTimeStamp
{
    // setup
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    components.timeZone = [NSTimeZone systemTimeZone];
    // details
    long year = (long)components.year;
    long month = (long)components.month;
    long week = (long)components.weekday;
    long day = (long)components.day;
    long hour = (long)components.hour;
    long minute = (long)components.minute;
    long second = (long)components.second;
    // print
    NSString *weekday = @"unknow";
    if (week == 1) weekday = @"Sun";
    if (week == 2) weekday = @"Mon";
    if (week == 3) weekday = @"Tue";
    if (week == 4) weekday = @"Wed";
    if (week == 5) weekday = @"Thu";
    if (week == 6) weekday = @"Fri";
    if (week == 7) weekday = @"Sat";
    if (printTimeStamp) {
        return [NSString stringWithFormat: @"%ld.%ld.%ld,%@,%ld:%ld:%ld，(%ld)", year, month, day, weekday, hour, minute, second, (long)[date timeIntervalSince1970]];
    } else {
        return [NSString stringWithFormat: @"%ld.%ld.%ld,%@,%ld:%ld:%ld", year, month, day, weekday, hour, minute, second];
    }
}

+ (NSString *)timeFromTimestamp:(long)timestamp printTimeStamp:(BOOL)printTimeStamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    // setup
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    components.timeZone = [NSTimeZone systemTimeZone];
    // details
    long year = (long)components.year;
    long month = (long)components.month;
    long week = (long)components.weekday;
    long day = (long)components.day;
    long hour = (long)components.hour;
    long minute = (long)components.minute;
    long second = (long)components.second;
    // print
    NSString *weekday = @"unknow";
    if (week == 1) weekday = @"Sun";
    if (week == 2) weekday = @"Mon";
    if (week == 3) weekday = @"Tue";
    if (week == 4) weekday = @"Wed";
    if (week == 5) weekday = @"Thu";
    if (week == 6) weekday = @"Fri";
    if (week == 7) weekday = @"Sat";
    if (printTimeStamp) {
        return [NSString stringWithFormat: @"%ld.%ld.%ld,%@,%ld:%ld:%ld，(%ld)", year, month, day, weekday, hour, minute, second, (long)[date timeIntervalSince1970]];
    } else {
        return [NSString stringWithFormat: @"%ld.%ld.%ld,%@,%ld:%ld:%ld", year, month, day, weekday, hour, minute, second];
    }
}

+ (long)getDayGapFromTheFirstDayThisWeek
{
    BOOL weekStartsOnMonday = YES;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate now]];
    components.timeZone = [NSTimeZone systemTimeZone];
    switch (components.weekday) {
        case 1:
            return weekStartsOnMonday ? 6:0;
        case 2:
            return weekStartsOnMonday ? 0:1;
        case 3:
            return weekStartsOnMonday ? 1:2;
        case 4:
            return weekStartsOnMonday ? 2:3;
        case 5:
            return weekStartsOnMonday ? 3:4;
        case 6:
            return weekStartsOnMonday ? 4:5;
        case 7:
            return weekStartsOnMonday ? 5:6;
        default:
            return components.weekday - 1; // 出错
    }
}

+ (long)getTotalTimeOfPeriods:(NSMutableArray<NSMutableArray *> *)periods
{
    long seconds = 0;
    for (int i=0; i<periods.count; i++) {
        NSMutableArray *period = periods[i];
        if (period.count == 2) {
            seconds = seconds + ([period[1] longValue] - [period[0] longValue]);
        }
    }
    return seconds;
}

@end
