//
//  MirrorDataManager.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import "MirrorDataManager.h"
#import "MirrorMacro.h"
#import "MirrorStorage.h"

@implementation MirrorDataManager

#pragma mark - Get tasks

+ (NSMutableArray<MirrorDataModel *> *)activatedTasksWithAddTask
{
    NSMutableArray<MirrorDataModel *> *activatedTasksWithAddTask = [MirrorDataManager activatedTasks];
    if (activatedTasksWithAddTask.count < kMaxTaskNum) {
        //cell数量不足的时候必加add task cell
        MirrorDataModel *fakeModel = [[MirrorDataModel alloc] initWithTitle:nil createdTime:nil colorType:nil isArchived:nil periods:nil isAddTask:YES];
        [activatedTasksWithAddTask addObject:fakeModel];
    }
    return activatedTasksWithAddTask;
}

+ (NSMutableArray<MirrorDataModel *> *)activatedTasks
{
    NSMutableArray<MirrorDataModel *> *activatedTasks = [NSMutableArray new];
    NSMutableArray<MirrorDataModel *> *allTasks = [MirrorDataManager allTasks];
    for (int i=0; i<allTasks.count; i++) {
        MirrorDataModel *model = allTasks[i];
        if (!model.isArchived) {
            [activatedTasks addObject:model];
        }
    }
    return activatedTasks;
}

+ (NSMutableArray<MirrorDataModel *> *)archivedTasks
{
    NSMutableArray<MirrorDataModel *> *archivedTasks = [NSMutableArray new];
    NSMutableArray<MirrorDataModel *> *allTasks = [MirrorDataManager allTasks];
    for (int i=0; i<allTasks.count; i++) {
        MirrorDataModel *model = allTasks[i];
        if (model.isArchived) {
            [archivedTasks addObject:model];
        }
    }
    return archivedTasks;
}

#pragma mark - Get tasks within a day/month/year
// ❗️从缓存中拿出来的long必须用longValue处理一下，不然会出现溢出

//+ (NSMutableArray<MirrorDataModel *> *)todayTasks
//{
//    NSMutableArray<MirrorDataModel *> *allTasks = [MirrorDataManager allTasks];
//    for (int i=0; i<allTasks.count; i++) {
//        MirrorDataModel *task = allTasks[i];
//
//    }
//}

#pragma mark - Private methods

+ (NSMutableArray<MirrorDataModel *> *)allTasks // Dictionaries by definition are unordered. So I used an array to do the trick
{
    // 把所有task加到一个array里
    NSMutableArray<MirrorDataModel *> *allTasks = [NSMutableArray new];
    NSMutableDictionary *dict = [[MirrorStorage sharedInstance] retriveMirrorData];
    for (id taskName in dict.allKeys) {
        MirrorDataModel *task = dict[taskName];
        [allTasks addObject:task];
    }
    // sort
    NSSortDescriptor *sdSortDate = [NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:YES];
    allTasks = [NSMutableArray arrayWithArray:[allTasks sortedArrayUsingDescriptors:@[sdSortDate]]];
    return allTasks;
}

+ (void)test
{
    [MirrorDataManager startedTimeToday];
    [MirrorDataManager startedTimeThisWeek];
    [MirrorDataManager startedTimeThisMonth];
    [MirrorDataManager startedTimeThisYear];;
}

+ (long)startedTimeToday // 今天起始点的时间戳
{
    // setup
    NSDate *today = [NSDate now];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:today];
    components.timeZone = [NSTimeZone systemTimeZone];
    // details
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    // get date
    NSDate *combinedDate = [gregorian dateFromComponents:components];
    long timeStamp = [combinedDate timeIntervalSince1970];
    [MirrorDataManager _printTime:timeStamp info:@"今天起始点的时间戳"];
    return timeStamp;
}

+ (long)startedTimeThisWeek // 本周起始点的时间戳
{
    // setup
    NSDate *today = [NSDate now];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:today];
    components.timeZone = [NSTimeZone systemTimeZone];
    // details
// ❗️错误操作：weekday比较特殊，把weekday设置为1是不能直接跳到本周的第一天的，因为真实的本周第一天的year、month都有可能发生变化。这里使用往前减数的方法手动计算本周起始点的时间戳
//  components.weekday = 1;
//  components.hour = 0;
//  components.minute = 0;
//  components.second = 0;
// ❗️正确操作：先拿到今天0点的时间，然后看今天比周日(一周的第一天)多了几天，再计算这周的起始时间
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    long todayZero = [[gregorian dateFromComponents:components] timeIntervalSince1970];
    long thisWeekZero = todayZero - (components.weekday - 1) * 86400;
    // get date
    [MirrorDataManager _printTime:thisWeekZero info:@"今天起始点的时间戳"];
    return thisWeekZero;
}

+ (long)startedTimeThisMonth // 本月起始点的时间戳
{
    // setup
    NSDate *today = [NSDate now];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:today];
    components.timeZone = [NSTimeZone systemTimeZone];
    // details
    components.day = 1;
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    // get date
    NSDate *combinedDate = [gregorian dateFromComponents:components];
    long timeStamp = [combinedDate timeIntervalSince1970];
    [MirrorDataManager _printTime:timeStamp info:@"本月起始点的时间戳"];
    return timeStamp;
}

+ (long)startedTimeThisYear // 今年起始点的时间戳
{
    // setup
    NSDate *today = [NSDate now];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:today];
    components.timeZone = [NSTimeZone systemTimeZone];
    // details
    components.month = 1;
    components.day = 1;
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    // get date
    NSDate *combinedDate = [gregorian dateFromComponents:components];
    long timeStamp = [combinedDate timeIntervalSince1970];
    [MirrorDataManager _printTime:timeStamp info:@"今年起始点的时间戳"];
    return timeStamp;
}

+ (void)_printTime:(long)timeStamp info:(NSString *)info
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
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
    NSLog(@"gizmo %@: %ld年%ld月%ld日，一周的第%ld天，%ld:%ld:%ld，时间戳为%ld，与此时此刻的时间差为%ld",info, year, month, day, week, hour, minute, second, (long)[date timeIntervalSince1970], (long)[[NSDate now] timeIntervalSince1970] - (long)[date timeIntervalSince1970]);
}

@end
