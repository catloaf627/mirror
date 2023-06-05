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
#import <AudioToolbox/AudioToolbox.h>
#import "MirrorTimeText.h"

@implementation MirrorStorage

#pragma mark - Time VC需要的信息


+ (NSString *)isGoingOnTask
{
    NSMutableArray<MirrorRecordModel *> *allRecords = [MirrorStorage retriveMirrorRecords];
    if (allRecords.count > 0 && allRecords[allRecords.count-1].endTime == 0) {
        return allRecords[allRecords.count-1].taskName;
    }
    return @"";
}

+ (NSMutableArray<MirrorTaskModel *> *)tasksWithoutArchiveWithAddNew
{
    NSMutableArray <MirrorTaskModel *> *tasks = [MirrorStorage retriveMirrorTasks];
    NSMutableArray <MirrorTaskModel *> *tasksWithoutArchive = [NSMutableArray new];
    for (int i=0; i<tasks.count; i++) {
        if (!tasks[i].isArchived) {
            [tasksWithoutArchive addObject:tasks[i]];
        }
    }
    MirrorTaskModel *fakemodel = [[MirrorTaskModel alloc] initWithTitle:@"" createdTime:0 colorType:0 isArchived:NO isHidden:NO isAddTask:YES];
    [tasksWithoutArchive addObject:fakemodel];
    return tasksWithoutArchive;
}

#pragma mark - Actions

+ (void)createTask:(MirrorTaskModel *)task
{
    NSMutableArray <MirrorTaskModel *> *tasks = [MirrorStorage retriveMirrorTasks];
    [tasks addObject:task];
    NSLog(@"Create");
    [MirrorStorage saveMirrorTasks:tasks];
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorTaskCreateNotification object:nil userInfo:nil];
    AudioServicesPlaySystemSound((SystemSoundID)kAudioClick);
}

+ (void)deleteTask:(NSString *)taskName
{
    // 删掉task
    NSMutableArray <MirrorTaskModel *> *tasks = [MirrorStorage retriveMirrorTasks];
    NSInteger deletedIndex = NSNotFound;
    for (int i=0; i<tasks.count; i++) {
        if ([tasks[i].taskName isEqualToString:taskName]) {
            NSLog(@"Delete task");
            deletedIndex = i;
            break;
        }
    }
    if (deletedIndex != NSNotFound) [tasks removeObjectAtIndex:deletedIndex];
    [MirrorStorage saveMirrorTasks:tasks];
    // 删掉这个task的所有records
    NSMutableArray <MirrorRecordModel *> *records = [MirrorStorage retriveMirrorRecords];
    NSMutableArray <MirrorRecordModel *> *validRecords = [NSMutableArray new];
    for (int i=0; i<records.count; i++) {
        if (![records[i].taskName isEqualToString:taskName]) {
            [validRecords addObject:records[i]];
        } else {
            NSLog(@"Delete record");
        }
    }
    [MirrorStorage saveMirrorRecords:validRecords];
    // 通知
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorTaskDeleteNotification object:nil userInfo:nil];
    AudioServicesPlaySystemSound((SystemSoundID)kAudioClick);
}

+ (void)archiveTask:(NSString *)taskName
{
    NSMutableArray <MirrorTaskModel *> *tasks = [MirrorStorage retriveMirrorTasks];
    for (int i=0; i<tasks.count; i++) {
        if ([tasks[i].taskName isEqualToString:taskName]) {
            NSLog(@"Archive");
            tasks[i].isArchived = YES;
            break;
        }
    }
    [MirrorStorage saveMirrorTasks:tasks];
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorTaskArchiveNotification object:nil userInfo:nil];
    AudioServicesPlaySystemSound((SystemSoundID)kAudioClick);
}

+ (void)cancelArchiveTask:(NSString *)taskName
{
    NSMutableArray <MirrorTaskModel *> *tasks = [MirrorStorage retriveMirrorTasks];
    for (int i=0; i<tasks.count; i++) {
        if ([tasks[i].taskName isEqualToString:taskName]) {
            NSLog(@"Cancel Archive");
            tasks[i].isArchived = NO;
            break;
        }
    }
    [MirrorStorage saveMirrorTasks:tasks];
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorTaskArchiveNotification object:nil userInfo:nil];
    AudioServicesPlaySystemSound((SystemSoundID)kAudioClick);
}

+ (void)switchHiddenTask:(NSString *)taskName
{
    NSMutableArray <MirrorTaskModel *> *tasks = [MirrorStorage retriveMirrorTasks];
    for (int i=0; i<tasks.count; i++) {
        if ([tasks[i].taskName isEqualToString:taskName]) {
            if (tasks[i].isHidden == NO) {
                NSLog(@"Hide");
                tasks[i].isHidden = YES;
            } else {
                NSLog(@"Cancel Hide");
                tasks[i].isHidden = NO;
            }
            break;
        }
    }
    [MirrorStorage saveMirrorTasks:tasks];
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorTaskHiddenNotification object:nil userInfo:nil];
    AudioServicesPlaySystemSound((SystemSoundID)kAudioClick);
}

+ (void)editTask:(NSString *)oldName name:(NSString *)newName
{
    NSMutableArray <MirrorTaskModel *> *tasks = [MirrorStorage retriveMirrorTasks];
    for (int i=0; i<tasks.count; i++) {
        if ([tasks[i].taskName isEqualToString:oldName]) {
            NSLog(@"Edit name");
            tasks[i].taskName = newName;
            break;
        }
    }
    [MirrorStorage saveMirrorTasks:tasks];
    NSMutableArray <MirrorRecordModel *> *records = [MirrorStorage retriveMirrorRecords];
    for (int i=0; i<records.count; i++) {
        if ([records[i].taskName isEqualToString:oldName]) {
            NSLog(@"Edit record name");
            records[i].taskName = newName;
        }
    }
    [MirrorStorage saveMirrorRecords:records];
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorTaskEditNotification object:nil userInfo:nil];
    AudioServicesPlaySystemSound((SystemSoundID)kAudioClick);
}



+ (void)editTask:(NSString *)taskName color:(MirrorColorType)color
{
    NSMutableArray <MirrorTaskModel *> *tasks = [MirrorStorage retriveMirrorTasks];
    for (int i=0; i<tasks.count; i++) {
        if ([tasks[i].taskName isEqualToString:taskName]) {
            NSLog(@"Edit color");
            tasks[i].color = color;
            break;
        }
    }
    [MirrorStorage saveMirrorTasks:tasks];
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorTaskEditNotification object:nil userInfo:nil];
    AudioServicesPlaySystemSound((SystemSoundID)kAudioClick);
}

+ (void)reorderTasks:(NSMutableArray <MirrorTaskModel *> *)taskArray
{
    [MirrorStorage saveMirrorTasks:taskArray]; // reorder 的话直接保存数组即可
    NSLog(@"Edit order");
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorTaskChangeOrderNotification object:nil userInfo:nil];
    AudioServicesPlaySystemSound((SystemSoundID)kAudioClick);
}

+ (void)savePeriodWithTaskname:(NSString *)taskName startAt:(NSDate *)startDate endAt:(NSDate *)endDate
{
    [MirrorStorage p_startTask:taskName at:startDate];
    [MirrorStorage p_stopTask:taskName at:endDate];
    NSLog(@"Save period start %@, end %@", [MirrorTool timeFromDate:startDate printTimeStamp:NO],  [MirrorTool timeFromDate:endDate printTimeStamp:NO]);
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorTaskStopNotification object:nil userInfo:nil]; // 直接保存的也报stop
    AudioServicesPlaySystemSound((SystemSoundID)kAudioClick);
}

+ (void)startTask:(NSString *)taskName at:(NSDate *)accurateDate
{
    [MirrorStorage p_startTask:taskName at:accurateDate];
    NSLog(@"Start at %@", [MirrorTool timeFromDate:accurateDate printTimeStamp:NO]);
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorTaskStartNotification object:nil userInfo:nil];
    AudioServicesPlaySystemSound((SystemSoundID)kAudioClick);
}

+ (void)p_startTask:(NSString *)taskName at:(NSDate *)accurateDate
{
    NSDate *date = [self dateWithoutSeconds:accurateDate];
    NSMutableArray <MirrorRecordModel *> *records = [MirrorStorage retriveMirrorRecords];
    MirrorRecordModel *newRecord = [[MirrorRecordModel alloc] initWithTitle:taskName startTime:round([date timeIntervalSince1970]) endTime:0];
    [records addObject:newRecord];
    [MirrorStorage saveMirrorRecords:records];
}

+ (void)stopTask:(NSString *)taskName at:(NSDate *)accurateDate
{
    [MirrorStorage p_stopTask:taskName at:accurateDate];
    NSLog(@"Stop at %@", [MirrorTool timeFromDate:accurateDate printTimeStamp:NO]);
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorTaskStopNotification object:nil userInfo:nil];
    AudioServicesPlaySystemSound((SystemSoundID)kAudioClick);
}

+ (void)p_stopTask:(NSString *)taskName at:(NSDate *)accurateDate // 这里taskname没用
{
    NSDate *date = [self dateWithoutSeconds:accurateDate];
    NSMutableArray <MirrorRecordModel *> *records = [MirrorStorage retriveMirrorRecords];
    MirrorRecordModel *recordToBeEditted = records[records.count-1]; // 最后(新)一个record
    long start = recordToBeEditted.startTime;
    long end = [date timeIntervalSince1970];
    long length = end - start;
    NSLog(@"%@计时结束 %ld", taskName, length);
    
        if (length >= kMinSeconds) { // 一分钟以上开始记录（00:00处切割）
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:start];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:end];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *startComponents = [gregorian components:NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond fromDate:startDate];
            NSDateComponents *endComponents = [gregorian components:NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond fromDate:endDate];
            startComponents.timeZone = [NSTimeZone systemTimeZone];
            endComponents.timeZone = [NSTimeZone systemTimeZone];
            BOOL isDefinitelyTheSomeDay = startComponents.year == endComponents.year && startComponents.month == endComponents.month && startComponents.day == endComponents.day; // 日期一模一样
            BOOL isTechnicallyTheSameDay = endComponents.hour == 0 && endComponents.minute == 0 && endComponents.second == 0 && ([endDate timeIntervalSince1970] - [startDate timeIntervalSince1970]) <= 86400; // 日期不一样结束时间为0点，且持续时间<=一天
            if (isDefinitelyTheSomeDay || isTechnicallyTheSameDay) { // 开始和结束在同一天，直接记录 (存在原处)
                recordToBeEditted.endTime = round([date timeIntervalSince1970]);
                records[records.count -1] = recordToBeEditted;
            } else { //开始和结束不在同一天，在00:00处切割分段
                NSDateComponents *endComponent0 = [gregorian components:NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond fromDate:startDate];
                endComponent0.hour = 23;
                endComponent0.minute = 59;
                endComponent0.second = 59;
                long endTime0 = [[gregorian dateFromComponents:endComponent0] timeIntervalSince1970] + 1;
                recordToBeEditted.endTime = endTime0;
                records[records.count -1] = recordToBeEditted;

                long startTimei = endTime0;
                long endTimei = startTimei + 86400;
                while (endTimei < end) {
                    MirrorRecordModel *newRecord = [[MirrorRecordModel alloc] initWithTitle:taskName startTime:startTimei endTime:endTimei];
                    [records addObject:newRecord];
                    startTimei = startTimei + 86400;
                    endTimei = startTimei + 86400;
                }
                MirrorRecordModel *newRecord = [[MirrorRecordModel alloc] initWithTitle:taskName startTime:startTimei endTime:end];
                [records addObject:newRecord];// 最后一个分段（新插入）
            }
        } else {
            [records removeObjectAtIndex:records.count-1];
        }
    [MirrorStorage saveMirrorRecords:records];
}

+ (TaskNameExistsType)taskNameExists:(NSString *)newTaskName
{
    NSMutableArray <MirrorTaskModel *> *tasks = [MirrorStorage retriveMirrorTasks];
    for (int i=0; i<tasks.count; i++) {
        if ([tasks[i].taskName isEqualToString:newTaskName]) {
            if (tasks[i].isArchived) {
                return TaskNameExistsTypeExistsInArchivedTasks;
            } else {
                return TaskNameExistsTypeExistsInCurrentTasks;
            }
        }
    }
    return TaskNameExistsTypeValid;
}

+ (void)deletePeriodAtIndex:(NSInteger)index
{
    NSMutableArray *records = [MirrorStorage retriveMirrorRecords];
    [records removeObjectAtIndex:index];
    [MirrorStorage saveMirrorRecords:records];
    NSLog(@"Period deleted");
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorPeriodDeleteNotification object:nil userInfo:nil];
    AudioServicesPlaySystemSound((SystemSoundID)kAudioClick);
}

+ (void)editPeriodIsStartTime:(BOOL)isStartTime to:(long)timestamp periodIndex:(NSInteger)index
{
    NSMutableArray<MirrorRecordModel *> *records = [MirrorStorage retriveMirrorRecords];
    if (isStartTime) {
        records[index].startTime = timestamp;
    } else {
        records[index].endTime = timestamp;
    }
    [MirrorStorage saveMirrorRecords:records];
    NSLog(@"Period is edited");
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorPeriodEditNotification object:nil userInfo:nil];
    AudioServicesPlaySystemSound((SystemSoundID)kAudioClick);
}

#pragma mark - Local database

+ (void)saveMirrorTasks:(NSMutableArray<MirrorTaskModel *> *)tasks // 归档
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@{TASKS:tasks, RECORDS:[MirrorStorage retriveMirrorRecords], HISTORY:[MirrorStorage retriveMirrorHistory], SECONDS:[MirrorStorage retriveSecondsFromGMT]} requiringSecureCoding:YES error:nil];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:@"mirror.data"];
    [data writeToFile:filePath atomically:YES];
}

+ (NSMutableArray<MirrorTaskModel *> *)retriveMirrorTasks // 解档
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:@"mirror.data"];
    NSData *storedEncodedObject = [NSData dataWithContentsOfFile:filePath options:0 error:nil];
    NSDictionary *dataDict = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[MirrorTaskModel.class, MirrorRecordModel.class, NSMutableArray.class, NSArray.class, NSMutableDictionary.class, NSDictionary.class]] fromData:storedEncodedObject error:nil];
    if ([dataDict[TASKS] isKindOfClass:[NSMutableArray<MirrorTaskModel *> class]] && [dataDict[RECORDS] isKindOfClass:[NSMutableArray<MirrorRecordModel *> class]] && [dataDict[SECONDS] isKindOfClass:[NSNumber class]]) {
        NSMutableArray<MirrorTaskModel *> *tasks = dataDict[TASKS];
        return tasks;
    } else {
        return [NSMutableArray new];
    }
}

+ (void)saveMirrorRecords:(NSMutableArray<MirrorRecordModel *> *)records // 归档
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@{TASKS:[MirrorStorage retriveMirrorTasks], RECORDS:records, HISTORY:[MirrorStorage retriveMirrorHistory], SECONDS:[MirrorStorage retriveSecondsFromGMT]} requiringSecureCoding:YES error:nil];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:@"mirror.data"];
    [data writeToFile:filePath atomically:YES];
}

+ (NSMutableArray<MirrorRecordModel *> *)retriveMirrorRecords // 解档
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:@"mirror.data"];
    NSData *storedEncodedObject = [NSData dataWithContentsOfFile:filePath options:0 error:nil];
    NSDictionary *dataDict = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[MirrorTaskModel.class, MirrorRecordModel.class, NSMutableArray.class, NSArray.class, NSMutableDictionary.class, NSDictionary.class]] fromData:storedEncodedObject error:nil];
    if ([dataDict[TASKS] isKindOfClass:[NSMutableArray<MirrorTaskModel *> class]] && [dataDict[RECORDS] isKindOfClass:[NSMutableArray<MirrorRecordModel *> class]] && [dataDict[SECONDS] isKindOfClass:[NSNumber class]]) {
        NSMutableArray<MirrorRecordModel *> *records = dataDict[RECORDS];
        for (int i=0; i<records.count; i++) {
            records[i].originalIndex = i;
        }
        return records;
    } else {
        return [NSMutableArray new];
    }
}

+ (void)saveMirrorHistory:(NSMutableDictionary<NSString *, NSMutableDictionary *> *)history
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@{TASKS:[MirrorStorage retriveMirrorTasks], RECORDS:[MirrorStorage retriveMirrorRecords], HISTORY:history, SECONDS:[MirrorStorage retriveSecondsFromGMT]} requiringSecureCoding:YES error:nil];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:@"mirror.data"];
    [data writeToFile:filePath atomically:YES];
}

+ (NSMutableDictionary<NSString *, NSMutableDictionary *> *)retriveMirrorHistory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:@"mirror.data"];
    NSData *storedEncodedObject = [NSData dataWithContentsOfFile:filePath options:0 error:nil];
    NSDictionary *dataDict = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[MirrorTaskModel.class, MirrorRecordModel.class, NSMutableArray.class, NSArray.class, NSMutableDictionary.class, NSDictionary.class]] fromData:storedEncodedObject error:nil];
    if ([dataDict[TASKS] isKindOfClass:[NSMutableArray<MirrorTaskModel *> class]] && [dataDict[RECORDS] isKindOfClass:[NSMutableArray<MirrorRecordModel *> class]] && [dataDict[HISTORY] isKindOfClass:[NSMutableDictionary class]] && [dataDict[SECONDS] isKindOfClass:[NSNumber class]]) {
        NSMutableDictionary<NSString *, NSMutableDictionary *> *history = dataDict[HISTORY];
        return history;
    } else {
        return [NSMutableDictionary new];
    }
}

+ (void)saveSecondsFromGMT:(NSNumber *)secondFromGMT // 归档
{
    /*
     Standard     0h                         2023年5月2日13时                 标准时间
     Bejing      +8h(oldSecondsFromGMT)      2023年5月2日21时           （之前数字被切割的标准）
     New York    -4h                         2023年5月2日9时       想要展示为2023年5月2日21时，数据库数据需要+12
     London      +1h                         2023年5月2日14时      想要展示为2023年5月2日21时，数据库数据需要+7
     Tokyo       +9h                         2023年5月2日22时      想要展示为2023年5月2日21时，数据库数据需要-1
     */
    NSInteger timezoneGap = [[MirrorStorage retriveSecondsFromGMT] integerValue] - [secondFromGMT integerValue];
    if (timezoneGap==0) {
        return;
    } else {
        // 改tasks (createtime)
        NSMutableArray<MirrorTaskModel *> *tasks = [MirrorStorage retriveMirrorTasks];
        for (int i=0; i<tasks.count; i++) {
            tasks[i].createdTime = tasks[i].createdTime + timezoneGap;
        }
        [MirrorStorage saveMirrorTasks:tasks];
        // 改records
        NSMutableArray<MirrorRecordModel *> *records = [MirrorStorage retriveMirrorRecords];
        for (int i=0; i<records.count; i++) {
            records[i].startTime = records[i].startTime + timezoneGap;
            if (records[i].endTime != 0) records[i].endTime = records[i].endTime + timezoneGap;
        }
        [MirrorStorage saveMirrorRecords:records];
        // 改timezone
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@{TASKS:[MirrorStorage retriveMirrorTasks], RECORDS:[MirrorStorage retriveMirrorRecords], HISTORY:[MirrorStorage retriveMirrorHistory], SECONDS:secondFromGMT} requiringSecureCoding:YES error:nil];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        NSString *filePath = [path stringByAppendingPathComponent:@"mirror.data"];
        [data writeToFile:filePath atomically:YES];
    }
}

+ (NSNumber *)retriveSecondsFromGMT // 解档
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:@"mirror.data"];
    NSData *storedEncodedObject = [NSData dataWithContentsOfFile:filePath options:0 error:nil];
    NSDictionary *dataDict = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[MirrorTaskModel.class, MirrorRecordModel.class, NSMutableArray.class, NSArray.class, NSMutableDictionary.class, NSDictionary.class]] fromData:storedEncodedObject error:nil];
    if ([dataDict[TASKS] isKindOfClass:[NSMutableArray<MirrorTaskModel *> class]] && [dataDict[RECORDS] isKindOfClass:[NSMutableArray<MirrorRecordModel *> class]] && [dataDict[SECONDS] isKindOfClass:[NSNumber class]]) {
        NSNumber *secondFromGMT = dataDict[SECONDS];
        return secondFromGMT;
    } else {
        return @([NSTimeZone systemTimeZone].secondsFromGMT);
    }
}

+ (NSMutableArray<MirrorRecordModel *> *)p_retriveMirrorRecordsWithoutHidden
{
    NSMutableArray<MirrorTaskModel *> *allTasks = [MirrorStorage retriveMirrorTasks];
    NSMutableDictionary *taskHiddenState = [NSMutableDictionary new];
    for (int i=0; i<allTasks.count; i++) {
        MirrorTaskModel *task = allTasks[i];
        if (task.isHidden) {
            [taskHiddenState setValue:@(YES) forKey:task.taskName];
        } else {
            [taskHiddenState setValue:@(NO) forKey:task.taskName];
        }
    }
    NSMutableArray<MirrorRecordModel *> *allRecords = [MirrorStorage retriveMirrorRecords];
    NSMutableArray<MirrorRecordModel *> *allRecordsWithoutHidden = [NSMutableArray new];
    for (int i=0; i<allRecords.count; i++) {
        MirrorRecordModel *record = allRecords[i];
        if ([taskHiddenState[record.taskName] boolValue]) {
            // 这条record被隐藏
        } else {
            [allRecordsWithoutHidden addObject:record];
        }
    }
    return allRecordsWithoutHidden;
}

#pragma mark - 取出部分数据

+ (MirrorTaskModel *)getTaskModelFromDB:(NSString *)taskName
{
    NSMutableArray<MirrorTaskModel *> *allTasks = [MirrorStorage retriveMirrorTasks];
    MirrorTaskModel *targetTask = nil;
    for (int i=0; i<allTasks.count; i++) {
        MirrorTaskModel *task = allTasks[i];
        if ([task.taskName isEqualToString:taskName]) {
            targetTask = task;
            break;
        }
    }
    return targetTask;
}

// 取出一个任务从古至今的所有records
+ (NSMutableArray<MirrorRecordModel *> *)getAllTaskRecords:(NSString *)taskName
{
    NSMutableArray<MirrorRecordModel *> *allRecords = [MirrorStorage retriveMirrorRecords];
    NSMutableArray<MirrorRecordModel *> *taskRecords = [NSMutableArray new];
    for (int recordIndex=0; recordIndex<allRecords.count; recordIndex++) {
        MirrorRecordModel *record = allRecords[recordIndex];
        if ([record.taskName isEqualToString:taskName]) {
            MirrorRecordModel *recordCopy = [[MirrorRecordModel alloc] initWithTitle:record.taskName startTime:record.startTime endTime:record.endTime];
            recordCopy.originalIndex = record.originalIndex;
            [taskRecords addObject:recordCopy];
        }
    }
    return taskRecords;
}

+ (NSMutableArray<MirrorRecordModel *> *)getTodayData
{
    // TODAY timestamp
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate now]];
    components.timeZone = [NSTimeZone systemTimeZone];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    long startTime = [[gregorian dateFromComponents:components] timeIntervalSince1970];
    long endTime = startTime + 86400;
    
    BOOL printDetailsToDebug = NO; // debug用
    NSMutableArray<MirrorRecordModel *> *targetRecords = [NSMutableArray<MirrorRecordModel *> new];
    NSMutableArray<MirrorRecordModel *> *allRecords = [MirrorStorage retriveMirrorRecords];

    for (int recordIndex=0; recordIndex<allRecords.count; recordIndex++) {
        MirrorRecordModel *record = allRecords[recordIndex];
        if (printDetailsToDebug) {
            NSLog(@"period数据：[%@,%@]，选取的时间段：[%@,%@]", [MirrorTool timeFromTimestamp:record.startTime printTimeStamp:NO], [MirrorTool timeFromTimestamp:record.endTime printTimeStamp:NO], [MirrorTool timeFromTimestamp:startTime printTimeStamp:NO], [MirrorTool timeFromTimestamp:endTime printTimeStamp:NO]);
        }
        if (record.endTime == 0) {
            if (printDetailsToDebug) NSLog(@"✖️正在计时中，不管");
            continue;
        }
        // r.end < starttime
        else if (record.endTime < startTime) {
            if (printDetailsToDebug) NSLog(@"✖️完整地发生在start time之前，不管");
        }
        // starttime<=r.start, r.end<=endtime
        else if (startTime <= record.startTime && record.endTime <= endTime) {
            if (printDetailsToDebug) NSLog(@"✔️完整地发生在start time和end time中间");
            MirrorRecordModel* recordCopy = [[MirrorRecordModel alloc] initWithTitle:record.taskName startTime:record.startTime endTime:record.endTime];
            recordCopy.originalIndex = record.originalIndex;
            [targetRecords addObject:recordCopy];
            
        }
        // endtime < r.start
        else if (endTime < record.startTime) {
            if (printDetailsToDebug) NSLog(@"✖️完整地发生在end time之后，不管");
        }
        // r.start<=starttime, startime<=r.end<=endtime ✔️跨越了start time，取后半段【省略，代码里不会存在records跨越start/end的情况（start/end必是某日的零点）】
        // starttime<=r.start<=endtime, endtime<=r.end ✔️跨越了end time，取前半段【省略，代码里不会存在records跨越start/end的情况（start/end必是某日的零点）】
        // r.start<=starttime && endtime<=r.end ✖️囊括了整个starttime到endtime【省略，代码里不会存在records跨越start/end的情况（start/end必是某日的零点）】
    }
    return targetRecords;
}

// 取出从startTime到endTime的所有条record，并按照MirrorDataModel的方式存储
+ (NSMutableArray<MirrorDataModel *> *)getAllRecordsInTaskOrderWithStart:(long)startTime end:(long)endTime
{
    BOOL printDetailsToDebug = NO; // debug用
    NSMutableDictionary<NSString *, NSMutableArray<MirrorRecordModel *> *> *dict = [NSMutableDictionary<NSString *, NSMutableArray<MirrorRecordModel *> *> new];
    
    NSMutableArray<MirrorRecordModel *> *allRecords = [NSMutableArray new];
    /*--------------------HISTORY PART-------------------*/
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond fromDate:[NSDate now]];
    components.timeZone = [NSTimeZone systemTimeZone];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    long todayLine = [[gregorian dateFromComponents:components] timeIntervalSince1970];
    long historyLine = todayLine - kNumOfEditableDay * 86400;
    if (startTime < historyLine) { // 需要从历史里找再循环，不需要从历史里找（records已经cover），直接跳过
        NSMutableDictionary<NSString *, NSMutableDictionary *> *allHistory = [MirrorStorage retriveMirrorHistory];
        for (id key in allHistory.allKeys) {
            if ([key integerValue]<= endTime && [key integerValue]>= startTime) {
                for (id taskName in allHistory[key].allKeys) {
                    // 在history里，一天同task的record已经被合并了。不再每一条知道具体的开始结束时间，只知道这一天这个task的总时间。
                    long taskTotalTime = [allHistory[key][taskName] integerValue];
                    MirrorRecordModel *record = [[MirrorRecordModel alloc] initWithTitle:taskName startTime:[key integerValue] endTime:[key integerValue]+taskTotalTime];
                    [allRecords addObject:record];
                }
            }
        }
    }
    /*--------------------HISTORY PART-------------------*/
    [allRecords addObjectsFromArray:[MirrorStorage p_retriveMirrorRecordsWithoutHidden]];

    /*------------------------筛选------------------------*/
    for (int recordIndex=0; recordIndex<allRecords.count; recordIndex++) {
        MirrorRecordModel *record = allRecords[recordIndex];
        if (printDetailsToDebug) {
            NSLog(@"period数据：[%@,%@]，选取的时间段：[%@,%@]", [MirrorTool timeFromTimestamp:record.startTime printTimeStamp:NO], [MirrorTool timeFromTimestamp:record.startTime printTimeStamp:NO], [MirrorTool timeFromTimestamp:startTime printTimeStamp:NO], [MirrorTool timeFromTimestamp:endTime printTimeStamp:NO]);
        }
        if (record.endTime == 0) {
            if (printDetailsToDebug) NSLog(@"✖️正在计时中，不管");
            continue;
        }
        // r.end < starttime
        else if (record.endTime < startTime) {
            if (printDetailsToDebug) NSLog(@"✖️完整地发生在start time之前，不管");
        }
        // starttime<=r.start, r.end<=endtime
        else if (startTime <= record.startTime && record.endTime <= endTime) {
            if (printDetailsToDebug) NSLog(@"✔️完整地发生在start time和end time中间");
            if (dict[record.taskName]) {
                NSMutableArray<MirrorRecordModel *> *value = dict[record.taskName];
                MirrorRecordModel *recordCopy = [[MirrorRecordModel alloc] initWithTitle:record.taskName startTime:record.startTime endTime:record.endTime];
                recordCopy.originalIndex = record.originalIndex;
                [value addObject:recordCopy];
                [dict setValue:value forKey:recordCopy.taskName];
            } else {
                NSMutableArray<MirrorRecordModel *> *value = [NSMutableArray<MirrorRecordModel *> new];
                MirrorRecordModel *recordCopy = [[MirrorRecordModel alloc] initWithTitle:record.taskName startTime:record.startTime endTime:record.endTime];
                recordCopy.originalIndex = record.originalIndex;
                [value addObject:recordCopy];
                [dict setValue:value forKey:record.taskName];
            }
        }
        // endtime < r.start
        else if (endTime < record.startTime) {
            if (printDetailsToDebug) NSLog(@"✖️完整地发生在end time之后，不管");
        }
        // r.start<=starttime, startime<=r.end<=endtime ✔️跨越了start time，取后半段【省略，代码里不会存在records跨越start/end的情况（start/end必是某日的零点）】
        // starttime<=r.start<=endtime, endtime<=r.end ✔️跨越了end time，取前半段【省略，代码里不会存在records跨越start/end的情况（start/end必是某日的零点）】
        // r.start<=starttime && endtime<=r.end ✖️囊括了整个starttime到endtime【省略，代码里不会存在records跨越start/end的情况（start/end必是某日的零点）】
    }
    NSMutableArray<MirrorDataModel *> *res = [NSMutableArray new];
    NSMutableArray<MirrorTaskModel *> *tasks = [MirrorStorage retriveMirrorTasks];
    for (int i=0 ;i<tasks.count; i++) { // 按照任务在mirror_task里的顺序
        MirrorTaskModel *task = tasks[i];
        if ([dict.allKeys containsObject:task.taskName] && !task.isHidden) { // 这个task在时间段内有数据
            MirrorDataModel *chartModel = [[MirrorDataModel alloc] initWithTask:task records:dict[task.taskName]];
            NSMutableArray<MirrorRecordModel *> *games = dict[@"打游戏"];
            for (int i=0; i<games.count; i++) {
                MirrorRecordModel *game = games[i];
                NSLog(@"start: %@, lasted: %@", [MirrorTimeText YYYYmmddWeekdayWithStart:game.startTime], @(game.endTime-game.startTime));
            }
            [res addObject:chartModel];
        }
    }
    return res;
}

+ (NSMutableDictionary<NSString*, NSMutableArray<MirrorDataModel *> *> *)getGridData
{
    NSMutableDictionary<NSString*, NSMutableArray<MirrorDataModel *> *> *gridData = [NSMutableDictionary<NSString*, NSMutableArray<MirrorDataModel *> *> new];
    NSMutableArray<MirrorTaskModel *> *allTasks = [MirrorStorage retriveMirrorTasks];
    
    /*--------------------HISTORY PART-------------------*/
    NSMutableDictionary<NSString *, NSMutableDictionary *> *allHistory = [MirrorStorage retriveMirrorHistory];
    for (id key in allHistory.allKeys) {
        NSMutableDictionary *oneDayDict = allHistory[key];
        NSMutableArray<MirrorDataModel *> *oneday = [NSMutableArray new];
        for (int i = 0; i<allTasks.count; i++) {
            NSString *taskName = allTasks[i].taskName;
            if ([oneDayDict.allKeys containsObject:taskName] && !allTasks[i].isHidden) {
                // 在history里，一天同task的record已经被合并了。不再每一条知道具体的开始结束时间，只知道这一天这个task的总时间。
                long taskTotalTime = [oneDayDict[taskName] integerValue];
                MirrorRecordModel *onlyRecord = [[MirrorRecordModel alloc] initWithTitle:taskName startTime:[key integerValue] endTime:[key integerValue] + taskTotalTime];
                MirrorDataModel *oneDayOneTask = [[MirrorDataModel alloc] initWithTask:allTasks[i] records:[@[onlyRecord] mutableCopy]];
                [oneday addObject:oneDayOneTask];
            }
        }
        [gridData setValue:oneday forKey:key];
    }
    
    /*--------------------RECORDS PART-------------------*/
    NSMutableArray<MirrorRecordModel *> *allRecords = [MirrorStorage p_retriveMirrorRecordsWithoutHidden];
     
    if (allRecords.count == 0) return gridData;
    
    NSString *key = [self keyOfTime:allRecords[0].startTime];
    NSMutableArray<MirrorRecordModel *> *recordsInTimeOrder = [NSMutableArray new];
    for (int recordIndex=0; recordIndex<allRecords.count; recordIndex++) {
        MirrorRecordModel *record = allRecords[recordIndex];
        if (![[self keyOfTime:record.startTime] isEqualToString:key]) { // 下一天了
            // sort
            NSMutableArray<MirrorDataModel *> *oneday = [NSMutableArray new];
            for (int i=0; i<allTasks.count; i++) {
                NSMutableArray<MirrorRecordModel *> *recordsInTaskOrder = [NSMutableArray new];
                for (int j=0; j<recordsInTimeOrder.count; j++) {
                    if ([recordsInTimeOrder[j].taskName isEqualToString:allTasks[i].taskName]) {
                        [recordsInTaskOrder addObject:recordsInTimeOrder[j]];
                    }
                }
                if (recordsInTaskOrder.count != 0) {
                    MirrorDataModel *oneDayOneTask = [[MirrorDataModel alloc] initWithTask:allTasks[i] records:recordsInTaskOrder];
                    [oneday addObject:oneDayOneTask];
                }
            }
            // save
            [gridData setValue:oneday forKey:key];
            // next loop
            key = [self keyOfTime:record.startTime];
            recordsInTimeOrder = [NSMutableArray new];
            [recordsInTimeOrder addObject:record];
        } else { // 还在这一天
            [recordsInTimeOrder addObject:record];
        }
    }
    
    // sort
    NSMutableArray<MirrorDataModel *> *oneday = [NSMutableArray new];
    for (int i=0; i<allTasks.count; i++) {
        NSMutableArray<MirrorRecordModel *> *recordsInTaskOrder = [NSMutableArray new];
        for (int j=0; j<recordsInTimeOrder.count; j++) {
            if ([recordsInTimeOrder[j].taskName isEqualToString:allTasks[i].taskName]) {
                [recordsInTaskOrder addObject:recordsInTimeOrder[j]];
            }
        }
        if (recordsInTaskOrder.count != 0) {
            MirrorDataModel *oneDayOneTask = [[MirrorDataModel alloc] initWithTask:allTasks[i] records:recordsInTaskOrder];
            [oneday addObject:oneDayOneTask];
        }
    }
    // save
    [gridData setValue:oneday forKey:key];
    
    return gridData;
}


#pragma mark - Privates

+ (NSString *)keyOfTime:(long)timestamp
{
    NSDate *originalDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond fromDate:originalDate];
    components.timeZone = [NSTimeZone systemTimeZone];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    NSDate *zeroDate = [gregorian dateFromComponents:components];
    
    return [@([zeroDate timeIntervalSince1970]) stringValue];
}

+ (NSDate *)dateWithoutSeconds:(NSDate *)date
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond fromDate:date];
    components.timeZone = [NSTimeZone systemTimeZone];
    components.second = 0;
    NSDate *dateWithoutSeconds = [gregorian dateFromComponents:components];
    return dateWithoutSeconds;
}

- (NSMutableArray<MirrorRecordModel *> *)pressureTestRecords // 压力测试，让当前数据翻倍
{
    NSInteger times = 500; // 想让数据量翻多少倍
    NSInteger offset = 11; // 每个数据往前走多少周
    NSMutableArray<MirrorRecordModel *> *records = [MirrorStorage retriveMirrorRecords];
    NSMutableArray<MirrorRecordModel *> *fakeRecords = [NSMutableArray new];
    BOOL shouldBreak = NO;
    for (int i=0; i<times; i++) {
        NSMutableArray<MirrorRecordModel *> *newRecords = [NSMutableArray new];;
        for (int j=0; j<records.count; j++) {
            CGFloat startTime =records[j].startTime - offset*7*86400*i;
            CGFloat endTime = records[j].endTime - offset*7*86400*i;
            if (startTime<0 || endTime<0) {
                shouldBreak = YES;
                break;
            }
            MirrorRecordModel *newRecord = [[MirrorRecordModel alloc] initWithTitle:records[j].taskName startTime:startTime endTime:endTime];
            [newRecords addObject:newRecord];
        }
        if (shouldBreak) break;
        [fakeRecords insertObjects:newRecords atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newRecords.count)]];
        NSLog(@"循环到了第%d轮, 已经生成了%lu条数据", i, (unsigned long)fakeRecords.count);
    }
    return fakeRecords;
}

@end
