//
//  MirrorStorage.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/10/24.
//

#import "MirrorStorage.h"
#import "NSMutableDictionary+MirrorDictionary.h"
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
    [MirrorStorage printTaskByName:task.taskName info:@"Create"];
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorTaskCreateNotification object:nil userInfo:nil];
}

+ (void)deleteTask:(NSString *)taskName
{
    // 在本地取出词典
    NSMutableDictionary *mirrorDict = [MirrorStorage retriveMirrorData];
    // 通过taskname删除task
    [mirrorDict removeObjectForKey:taskName];
    // 将mirror dict存回本地
    [MirrorStorage printTaskByName:taskName info:@"Delete"];
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
    [MirrorStorage printTaskByName:taskName info:@"Archive"];
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
    [MirrorStorage printTaskByName:newName info:@"Edit"];
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
    [allPeriods addObject:newPeriod];
    task.periods = allPeriods;
    // 保存更新好的task到本地
    [mirrorDict setValue:task forKey:taskName];
    // 将mirror dict存回本地
    [MirrorStorage saveMirrorData:mirrorDict];
    [MirrorStorage printTaskByName:taskName info:@"Start"];
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
        NSMutableArray *lastPeriod = [[NSMutableArray alloc] initWithArray:allPeriods[allPeriods.count-1]];
        long start = [lastPeriod[0] longValue];
        long end = [[NSDate now] timeIntervalSince1970];
        long length = end - start;
        NSLog(@"%@计时结束 %ld",[UIColor getEmoji:task.color], length);
        if (lastPeriod.count == 1 &&  length >= 10) { // 长度为10秒以上开始记录
            [lastPeriod addObject:@(round([[NSDate now] timeIntervalSince1970]))];
            allPeriods[allPeriods.count-1] = lastPeriod;
            savedType = length >= 86400 ? TaskSavedTypeSaved24H : TaskSavedTypeSaved;
        } else { // 错误格式或者10秒以下，丢弃这个task
            [allPeriods removeLastObject];
            savedType = (length < 10 && length >= 0) ? TaskSavedTypeTooShort : TaskSavedTypeError;
        }
        task.periods = allPeriods;
    }
    // 保存更新好的task到本地
    [mirrorDict setValue:task forKey:taskName];
    // 将mirror dict存回本地
    [MirrorStorage saveMirrorData:mirrorDict];
    [MirrorStorage printTaskByName:taskName info:@"Stop"];
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
//    [MirrorStorage printTaskByName:task.taskName info:@"-------Getting one task-------"];
    return task;
}

+ (MirrorDataModel *)getOngoingTaskFromDB
{
    NSMutableDictionary *tasks = [MirrorStorage retriveMirrorData];
    for (id taskName in tasks.allKeys) {
        MirrorDataModel *task = tasks[taskName];
        if (task.isOngoing) {
//            [MirrorStorage printTaskByName:task.taskName info:@"-------Getting ongoing task-------"];
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
}

#pragma mark - Log & Mocked data

+ (void)printTaskByName:(NSString *)taskName info:(NSString *)info
{
    MirrorDataModel *task = [MirrorStorage retriveMirrorData][taskName];
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
