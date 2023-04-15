//
//  MirrorStorage.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/10/24.
//

#import "MirrorStorage.h"
#import "UIColor+MirrorColor.h"
#import "MirrorLanguage.h"
#import "MirrorTool.h"
#import "MirrorMacro.h"

static NSString *const kMirrorDict = @"mirror_dict";

@implementation MirrorStorage

#pragma mark - Public

+ (void)createTask:(MirrorDataModel *)task
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [MirrorStorage retriveMirrorData];
    // 新增一个task
    [mirrorDict setValue:task forKey:task.taskName];
    // 将mirror dict存回本地
    [MirrorStorage saveMirrorData:mirrorDict];
    [MirrorStorage printTask:[MirrorStorage retriveMirrorData][task.taskName] info:@"Create"];
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorTaskCreateNotification object:nil userInfo:nil];
}

+ (void)deleteTask:(NSString *)taskName
{
    // 在本地取出词典
    NSMutableDictionary *mirrorDict = [MirrorStorage retriveMirrorData];
    // 通过taskname删除task
    [mirrorDict removeObjectForKey:taskName];
    // 将mirror dict存回本地
    [MirrorStorage printTask:[MirrorStorage retriveMirrorData][taskName] info:@"Delete"];
    [MirrorStorage saveMirrorData:mirrorDict];
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorTaskDeleteNotification object:nil userInfo:nil];
}

+ (void)archiveTask:(NSString *)taskName
{
    [MirrorStorage stopTask:taskName];
    // 在本地取出task
    NSMutableDictionary *mirrorDict = [MirrorStorage retriveMirrorData];
    // 取出这个task以便作修改
    MirrorDataModel *task = mirrorDict[taskName];
    // stop task first
    // 更新task的archive状态
    task.isArchived = YES;
    // 保存更新好的task到本地
    [mirrorDict setValue:task forKey:taskName];
    // 将mirror dict存回本地
    [MirrorStorage saveMirrorData:mirrorDict];
    [MirrorStorage printTask:[MirrorStorage retriveMirrorData][taskName] info:@"Archive"];
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorTaskArchiveNotification object:nil userInfo:nil];
}

+ (void)editTask:(NSString *)oldName color:(MirrorColorType)newColor name:(NSString *)newName
{
    // 在本地取出task
    NSMutableDictionary *mirrorDict = [MirrorStorage retriveMirrorData];
    // 取出这个task以便作修改
    MirrorDataModel *task = mirrorDict[oldName];
    // 更新task的color和taskname
    [mirrorDict removeObjectForKey:oldName];
    task.color = newColor;
    task.taskName = newName;
    // 保存更新好的task到本地
    [mirrorDict setValue:task forKey:newName];
    // 将mirror dict存回本地
    [MirrorStorage saveMirrorData:mirrorDict];
    [MirrorStorage printTask:[MirrorStorage retriveMirrorData][newName] info:@"Edit"];
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorTaskEditNotification object:nil userInfo:nil];
}

+ (void)startTask:(NSString *)taskName
{
    // 在本地取出task
    NSMutableDictionary *mirrorDict = [MirrorStorage retriveMirrorData];
    // 取出这个task以便作修改
    MirrorDataModel *task = mirrorDict[taskName];
    // 给task创建一个新的period，并给出这个period的起始时间（now）
    NSMutableArray *allPeriods = [[NSMutableArray alloc] initWithArray:task.periods];
    NSMutableArray *newPeriod = [[NSMutableArray alloc] initWithArray:@[@(round([[NSDate now] timeIntervalSince1970]))]];
    [allPeriods insertObject:newPeriod atIndex:0];
    task.periods = allPeriods;
    // 保存更新好的task到本地
    [mirrorDict setValue:task forKey:taskName];
    // 将mirror dict存回本地
    [MirrorStorage saveMirrorData:mirrorDict];
    [MirrorStorage printTask:[MirrorStorage retriveMirrorData][taskName] info:@"Start"];
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorTaskStartNotification object:nil userInfo:nil];
}

+ (void)stopTask:(NSString *)taskName
{
    TaskSavedType savedType = TaskSavedTypeNone;
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [MirrorStorage retriveMirrorData];
    // 取出这个task以便作修改
    MirrorDataModel *task = mirrorDict[taskName];
    // 将最后一个period取出来，给它一个结束时间（now）
    NSMutableArray *allPeriods = [[NSMutableArray alloc] initWithArray:task.periods];
    if (allPeriods.count > 0) {
        NSMutableArray *latestPeriod = [[NSMutableArray alloc] initWithArray:allPeriods[0]];
        long start = [latestPeriod[0] longValue];
        long end = [[NSDate now] timeIntervalSince1970];
        long length = end - start;
        NSLog(@"%@计时结束 %ld",[UIColor getEmoji:task.color], length);
        if (latestPeriod.count == 1 &&  length >= 10) { // 长度为10秒以上开始记录
            [latestPeriod addObject:@(round([[NSDate now] timeIntervalSince1970]))];
            allPeriods[0] = latestPeriod;
            savedType = length >= 86400 ? TaskSavedTypeSaved24H : TaskSavedTypeSaved;
        } else { // 错误格式或者10秒以下，丢弃这个task
            [allPeriods removeObjectAtIndex:0];
            savedType = (length < 10 && length >= 0) ? TaskSavedTypeTooShort : TaskSavedTypeError;
        }
        task.periods = allPeriods;
    }
    // 保存更新好的task到本地
    [mirrorDict setValue:task forKey:taskName];
    // 将mirror dict存回本地
    [MirrorStorage saveMirrorData:mirrorDict];
    [MirrorStorage printTask:[MirrorStorage retriveMirrorData][taskName] info:@"Stop"];
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorTaskStopNotification object:nil userInfo:@{@"taskName":taskName, @"TaskSavedType" : @(savedType)}];
}

+ (void)stopAllTasksExcept:(NSString *)exceptTaskName
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [MirrorStorage retriveMirrorData];
    // 大循环
    for (id taskName in mirrorDict.allKeys) {
        // 取出这个task以便作修改
        MirrorDataModel *task = mirrorDict[taskName];
        if ([task.taskName isEqualToString:exceptTaskName]) { // 被点击的task不要动
            continue;
        }
        if (!task.isOngoing) { // 不在计时中的task不要动
            continue;
        }
        [MirrorStorage stopTask:taskName];
    }
}

+ (TaskNameExistsType)taskNameExists:(NSString *)newTaskName
{
    NSMutableDictionary *mirrorDict = [MirrorStorage retriveMirrorData];
    for (id taskName in mirrorDict.allKeys) {
        if ([taskName isEqualToString:newTaskName]) {
            MirrorDataModel *task = mirrorDict[taskName];
            if (task.isArchived) {
                return TaskNameExistsTypeExistsInArchivedTasks;
            } else {
                return TaskNameExistsTypeExistsInCurrentTasks;
            }
        }
    }
    return TaskNameExistsTypeValid;
}

+ (MirrorDataModel *)getTaskFromDB:(NSString *)taskName
{
    NSMutableDictionary *tasks = [MirrorStorage retriveMirrorData];
    MirrorDataModel *task = tasks[taskName];
//    [MirrorStorage printTask:[MirrorStorage retriveMirrorData][task.taskName] info:@"-------Getting one task-------"];
    return task;
}

+ (MirrorDataModel *)getOngoingTaskFromDB
{
    NSMutableDictionary *tasks = [MirrorStorage retriveMirrorData];
    for (id taskName in tasks.allKeys) {
        MirrorDataModel *task = tasks[taskName];
        if (task.isOngoing) {
//            [MirrorStorage printTask:[MirrorStorage retriveMirrorData][task.taskName] info:@"-------Getting ongoing task-------"];
            return task;
        }
    }
    return nil;
}

#pragma mark - Local database

+ (void)saveMirrorData:(NSMutableDictionary *)mirrorDict // 归档
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mirrorDict requiringSecureCoding:YES error:nil];
    [[NSUserDefaults standardUserDefaults] setValue:data forKey:kMirrorDict];
}

+ (NSMutableDictionary *)retriveMirrorData // 解档
{
    NSData *storedEncodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kMirrorDict];
    NSMutableDictionary *mirrorDict = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[MirrorDataModel.class,NSMutableDictionary.class, NSMutableArray.class]] fromData:storedEncodedObject error:nil];
    return mirrorDict ?: [NSMutableDictionary new];
//    return [MirrorStorage fakeData];
}

+ (NSMutableDictionary *)fakeData
{
    NSMutableDictionary *fakeData = [NSMutableDictionary new];
    // Created time仅用于排序，随便写
    long today = [MirrorStorage startedTimeToday];
    long week = [MirrorStorage startedTimeThisWeek];
    long month = [MirrorStorage startedTimeThisMonth];
    long year = [MirrorStorage startedTimeThisYear];
    MirrorDataModel *englishData = [[MirrorDataModel alloc] initWithTitle:@"English" createdTime:0 colorType:MirrorColorTypeCellPink isArchived:NO periods:[@[@[@(year+10), @(year+20)], @[@(month+10), @(month+20)], @[@(week+10), @(week+20)], @[@(today+10), @(today+20)]] mutableCopy] isAddTask:NO];
    [fakeData setValue:englishData forKey:@"English"];
    MirrorDataModel *readingData = [[MirrorDataModel alloc] initWithTitle:@"Reading" createdTime:0 colorType:MirrorColorTypeCellYellow isArchived:NO periods:[@[ @[@(today+10), @(today+20)]] mutableCopy] isAddTask:NO];
    [fakeData setValue:readingData forKey:@"Reading"];
    return fakeData;
}

#pragma mark - Get certain timestamp

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
//    [MirrorStorage _printTime:timeStamp info:@"今天起始点的时间戳"];
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
// ❗️正确操作：先拿到今天0点的时间，然后看今天比周日(一周的第一天)多了几天，再计算这周的起始时间
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    long todayZero = [[gregorian dateFromComponents:components] timeIntervalSince1970];
    long thisWeekZero = todayZero - [MirrorTool getDayGapFromTheFirstDayThisWeek] * 86400;
    // get date
//    [MirrorStorage _printTime:thisWeekZero info:@"这周起始点的时间戳"];
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
//    [MirrorStorage _printTime:timeStamp info:@"本月起始点的时间戳"];
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
//    [MirrorStorage _printTime:timeStamp info:@"今年起始点的时间戳"];
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
    NSLog(@"%@: %ld年%ld月%ld日，一周的第%ld天，%ld:%ld:%ld，时间戳为%ld，与此时此刻的时间差为%ld",info, year, month, day, week, hour, minute, second, (long)[date timeIntervalSince1970], (long)[[NSDate now] timeIntervalSince1970] - (long)[date timeIntervalSince1970]);
}

#pragma mark - Log

+ (void)printTask:(MirrorDataModel *)task info:(NSString *)info
{
    if (!task) NSLog(@"❗️❗️❗️❗️❗️❗️❗️❗️ACTION FAILED❗️❗️❗️❗️❗️❗️❗️❗️");
    if (info) NSLog(@"%@%@", info, [UIColor getLongEmoji:task.color]);
    
    BOOL printTimestamp = NO; // 是否打印时间戳（平时不需要打印，出错debug的时候打印一下）
    NSString *tag = @"";
    tag = [tag stringByAppendingString:task.isArchived ? @"[":@" "];
    tag = [tag stringByAppendingString:[UIColor getEmoji:task.color]];
    tag = [tag stringByAppendingString:task.isArchived ? @"]":@" "];
    NSLog(@"%@%@, Created at %@",tag, task.taskName,  [MirrorTool timeFromTimestamp:task.createdTime printTimeStamp:printTimestamp]);
    for (int i=0; i<task.periods.count; i++) {
        if (task.periods[i].count == 1) {
            NSLog(@"[%@, ..........] 计时中..., ", [MirrorTool timeFromTimestamp:[task.periods[i][0] longValue] printTimeStamp:printTimestamp]);
        }
        if (task.periods[i].count == 2) {
            NSLog(@"[%@, %@] Lasted:%@, ",
                  [MirrorTool timeFromTimestamp:[task.periods[i][0] longValue] printTimeStamp:printTimestamp],
                  [MirrorTool timeFromTimestamp:[task.periods[i][1] longValue] printTimeStamp:printTimestamp],
                  [[NSDateComponentsFormatter new] stringFromTimeInterval:[task.periods[i][1] longValue]-[task.periods[i][0] longValue]]);
        }
    }
    
}

@end
