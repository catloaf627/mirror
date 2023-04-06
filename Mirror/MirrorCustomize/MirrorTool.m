//
//  MirrorTool.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import "MirrorTool.h"

@implementation MirrorTool

+ (void)printTime:(NSDate *)date info:(NSString *)info
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
    NSLog(@"gizmo %@: %ld年%ld月%ld日，一周的第%ld天，%ld:%ld:%ld，时间戳为%ld",info, year, month, day, week, hour, minute, second, (long)[date timeIntervalSince1970]);
}

+ (void)printTodayStartedTime
{
    // setup
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:today];
    components.timeZone = [NSTimeZone systemTimeZone];
    // details
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    NSDate *combinedDate = [gregorian dateFromComponents:components];
    [MirrorTool printTime:[NSDate now] info:@"现在的时间"];
    [MirrorTool printTime:combinedDate info:@"今天0:0:0的时间"];
}

@end
