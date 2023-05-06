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

static NSString *const kMirrorTasks = @"mirror_tasks";
static NSString *const kMirrorRecords = @"mirror_records";

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
    MirrorTaskModel *fakemodel = [[MirrorTaskModel alloc] initWithTitle:@"" createdTime:0 colorType:0 isArchived:NO isAddTask:YES];
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
    NSMutableArray <MirrorTaskModel *> *tasks = [MirrorStorage retriveMirrorTasks];
    NSInteger deletedIndex = NSNotFound;
    for (int i=0; i<tasks.count; i++) {
        if ([tasks[i].taskName isEqualToString:taskName]) {
            NSLog(@"Delete");
            deletedIndex = i;
            break;
        }
    }
    if (deletedIndex != NSNotFound) [tasks removeObjectAtIndex:deletedIndex];
    [MirrorStorage saveMirrorTasks:tasks];
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
    if (![taskName isEqualToString:recordToBeEditted.taskName]) {
        NSLog(@"出问题了出问题了出问题了出问题了");
    }
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
            
            if (startComponents.year == endComponents.year && startComponents.month == endComponents.month && startComponents.day == endComponents.day) { // 开始和结束在同一天，直接记录 (存在原处)
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

+ (void)changeDataWithTimezoneGap:(NSInteger)timezoneGap
{
    NSMutableArray<MirrorRecordModel *> *records = [MirrorStorage retriveMirrorRecords];
    for (int i=0; i<records.count; i++) {
        records[i].startTime = records[i].startTime + timezoneGap;
        if (records[i].endTime != 0) records[i].endTime = records[i].endTime + timezoneGap;
    }
    [MirrorStorage saveMirrorRecords:records];
}

+ (void)saveMirrorTasks:(NSMutableArray<MirrorTaskModel *> *)tasks // 归档
{
    for (int i=0; i<tasks.count; i++) {
        NSLog(@"name %@, color %ld, createdtime %ld, isArchived %@", tasks[i].taskName, tasks[i].color, tasks[i].createdTime, tasks[i].isArchived ? @"Y":@"N");
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tasks requiringSecureCoding:YES error:nil];
    [[NSUserDefaults standardUserDefaults] setValue:data forKey:kMirrorTasks];
}

+ (NSMutableArray<MirrorTaskModel *> *)retriveMirrorTasks // 解档
{
    NSData *storedEncodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kMirrorTasks];
    NSMutableArray<MirrorTaskModel *> *tasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[MirrorTaskModel.class, MirrorRecordModel.class, NSMutableArray.class,NSArray.class]] fromData:storedEncodedObject error:nil];
    return tasks ?: [NSMutableArray new];
}

+ (void)saveMirrorRecords:(NSMutableArray<MirrorRecordModel *> *)records // 归档
{
    for (int i=0; i<records.count; i++) {
        NSLog(@"name %@, [%ld, %ld]", records[i].taskName, records[i].startTime, records[i].endTime);
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:records requiringSecureCoding:YES error:nil];
    [[NSUserDefaults standardUserDefaults] setValue:data forKey:kMirrorRecords];
}

+ (NSMutableArray<MirrorRecordModel *> *)retriveMirrorRecords // 解档
{
    NSData *storedEncodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kMirrorRecords];
    NSMutableArray<MirrorRecordModel *> *records = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[MirrorTaskModel.class, MirrorRecordModel.class, NSMutableArray.class, NSArray.class]] fromData:storedEncodedObject error:nil];
    return records ?: [NSMutableArray new];
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
            recordCopy.originalIndex = recordIndex;
            [taskRecords addObject:recordCopy];
        }
    }
    return taskRecords;
}

// 取出从startTime到endTime的所有条record
+ (NSMutableArray<MirrorRecordModel *> *)getAllRecordsWithStart:(long)startTime end:(long)endTime
{
    BOOL printDetailsToDebug = YES; // debug用
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
            recordCopy.originalIndex = recordIndex;
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
    BOOL printDetailsToDebug = YES; // debug用
    NSMutableDictionary<NSString *, NSMutableArray<MirrorRecordModel *> *> *dict = [NSMutableDictionary<NSString *, NSMutableArray<MirrorRecordModel *> *> new];
    NSMutableArray<MirrorRecordModel *> *allRecords = [MirrorStorage retriveMirrorRecords];

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
                recordCopy.originalIndex = recordIndex;
                [value addObject:recordCopy];
                [dict setValue:value forKey:recordCopy.taskName];
            } else {
                NSMutableArray<MirrorRecordModel *> *value = [NSMutableArray<MirrorRecordModel *> new];
                MirrorRecordModel *recordCopy = [[MirrorRecordModel alloc] initWithTitle:record.taskName startTime:record.startTime endTime:record.endTime];
                recordCopy.originalIndex = recordIndex;
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
        if ([dict.allKeys containsObject:task.taskName]) { // 这个task在时间段内有数据
            MirrorDataModel *chartModel = [[MirrorDataModel alloc] initWithTask:task records:dict[task.taskName]];
            [res addObject:chartModel];
        }
    }
    return res;
}

+ (NSMutableDictionary<NSString*, NSMutableArray<MirrorDataModel *> *> *)getGridData
{
    NSMutableDictionary<NSString*, NSMutableArray<MirrorDataModel *> *> *gridData = [NSMutableDictionary<NSString*, NSMutableArray<MirrorDataModel *> *> new];
    
    NSMutableArray<MirrorTaskModel *> *allTasks = [MirrorStorage retriveMirrorTasks];
    NSMutableArray<MirrorRecordModel *> *allRecords = [MirrorStorage retriveMirrorRecords];
     
    if (allRecords.count == 0) return gridData;
    
    NSString *key = [self keyOfTime:allRecords[0].startTime];
    NSMutableArray<MirrorRecordModel *> *recordsInTimeOrder = [NSMutableArray new];
    for (int recordIndex=0; recordIndex<allRecords.count; recordIndex++) {
        MirrorRecordModel *record = allRecords[recordIndex];
        record.originalIndex = recordIndex;
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
                MirrorDataModel *oneDayOneTask = [[MirrorDataModel alloc] initWithTask:allTasks[i] records:recordsInTaskOrder];
                [oneday addObject:oneDayOneTask];
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
@end
