//
//  MirrorDataManager.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import "MirrorDataManager.h"
#import "MirrorMacro.h"

@implementation MirrorDataManager

#pragma mark - Get tasks

+ (NSMutableArray<MirrorDataModel *> *)activatedTasksWithAddTask
{
    NSMutableArray<MirrorDataModel *> *activatedTasksWithAddTask = [MirrorDataManager activatedTasks];
    if (activatedTasksWithAddTask.count < kMaxTaskNum) {
        //cell数量不足的时候必加add task cell
        [activatedTasksWithAddTask addObject:[[MirrorDataModel alloc]initWithTitle:nil createdTime:nil colorType:nil isArchived:nil isOngoing:nil isAddTask:YES]];
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
    NSMutableArray<MirrorDataModel *> *allTasks = [NSMutableArray new];
    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] valueForKey:@"mirror_dict"];
    for (id taskName in dict.allKeys) {
        MirrorColorType color = [UIColor colorFromString:dict[taskName][@"color"]];
        BOOL isArchived = [dict[taskName][@"is_archived"] boolValue];
        BOOL isOngoing = [dict[taskName][@"is_ongoing"] boolValue];
        long createdTime = [dict[taskName][@"created_time"] longValue];
        MirrorDataModel *model = [[MirrorDataModel alloc]initWithTitle:taskName createdTime:createdTime colorType:color isArchived:isArchived isOngoing:isOngoing isAddTask:NO];
        [allTasks addObject:model];
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
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:today];
    components.timeZone = [NSTimeZone systemTimeZone];
    // details
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    // get date
    NSDate *combinedDate = [gregorian dateFromComponents:components];
    [MirrorDataManager _printTime:combinedDate info:@"今天起始点的时间戳"];
    return [combinedDate timeIntervalSince1970];
}

+ (long)startedTimeThisWeek // 本周起始点的时间戳
{
    // setup
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:today];
    components.timeZone = [NSTimeZone systemTimeZone];
    // details
// ❗️weekday比较特殊，把weekday设置为1是不能直接跳到本周的第一天的，因为真实的本周第一天的year、month都有可能发生变化。这里使用往前减数的方法手动计算本周起始点的时间戳
//  components.weekday = 1;
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    // get date
    NSDate *combinedDate = [gregorian dateFromComponents:components];
    [MirrorDataManager _printTime:combinedDate info:@"本周起始点的时间戳"];
    return [combinedDate timeIntervalSince1970];
}

+ (long)startedTimeThisMonth // 本月起始点的时间戳
{
    // setup
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:today];
    components.timeZone = [NSTimeZone systemTimeZone];
    // details
    components.day = 1;
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    // get date
    NSDate *combinedDate = [gregorian dateFromComponents:components];
    [MirrorDataManager _printTime:combinedDate info:@"本月起始点的时间戳"];
    return [combinedDate timeIntervalSince1970];
}

+ (long)startedTimeThisYear // 今年起始点的时间戳
{
    // setup
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:today];
    components.timeZone = [NSTimeZone systemTimeZone];
    // details
    components.month = 1;
    components.day = 1;
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    // get date
    NSDate *combinedDate = [gregorian dateFromComponents:components];
    [MirrorDataManager _printTime:combinedDate info:@"今年起始点的时间戳"];
    return [combinedDate timeIntervalSince1970];
}

+ (void)_printTime:(NSDate *)date info:(NSString *)info
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
    NSLog(@"gizmo %@: %ld年%ld月%ld日，一周的第%ld天，%ld:%ld:%ld，时间戳为%ld，与此时此刻的时间差为%ld",info, year, month, day, week, hour, minute, second, (long)[date timeIntervalSince1970], (long)[[NSDate now] timeIntervalSince1970] - (long)[date timeIntervalSince1970]);
}

@end
