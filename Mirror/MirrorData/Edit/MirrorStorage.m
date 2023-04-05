//
//  MirrorStorage.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/10/24.
//

#import "MirrorStorage.h"
#import "NSMutableDictionary+MirrorDictionary.h"

static NSString *const kMirrorDict = @"mirror_dict";

@implementation MirrorStorage

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static MirrorStorage *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[MirrorStorage alloc]init];
    });
    return instance;
}

- (void)createTask:(MirrorDataModel *)task
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [[[NSUserDefaults standardUserDefaults] valueForKey:kMirrorDict] mutableCopy] ?: [NSMutableDictionary new];
    // 新增一个task
    [mirrorDict setValue: @{@"created_time" : @(task.createdTime),
                            @"color": [UIColor stringFromColor:task.color],
                            @"is_archived" : @(task.isArchived),
                            @"is_ongoing":@(NO),
                            @"periods":[NSMutableArray new]} forKey:task.taskName]; //即使这里存的时候用的是mutable array，真正存进去以后会还是__NSCFArray（non-mutable）
    // 将mirror dict存回本地
    [[NSUserDefaults standardUserDefaults] setValue:mirrorDict forKey:kMirrorDict];
}

- (void)deleteTask:(MirrorDataModel *)task
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [[[NSUserDefaults standardUserDefaults] valueForKey:kMirrorDict] mutableCopy];
    // 通过taskname删除task
    [mirrorDict removeObjectForKey:task.taskName];
    // 将mirror dict存回本地
    [[NSUserDefaults standardUserDefaults] setValue:mirrorDict forKey:kMirrorDict];
}

- (void)archiveTask:(MirrorDataModel *)task
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [[[NSUserDefaults standardUserDefaults] valueForKey:kMirrorDict] mutableCopy];
    // 取出这个task以便作修改
    NSMutableDictionary *taskDict = [mirrorDict[task.taskName] mutableCopy];
    // 更新task的archive状态
    [taskDict setValue:@(YES) forKey:@"is_archived"];
    // 保存更新好的task到本地
    [mirrorDict setValue:taskDict forKey:task.taskName];
    // 将mirror dict存回本地
    [[NSUserDefaults standardUserDefaults] setValue:mirrorDict forKey:kMirrorDict];
}

- (void)editTask:(MirrorDataModel *)task color:(MirrorColorType)newColor name:(NSString *)newName
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [[[NSUserDefaults standardUserDefaults] valueForKey:kMirrorDict] mutableCopy];
    // 取出这个task以便作修改
    NSMutableDictionary *taskDict = [mirrorDict[task.taskName] mutableCopy];
    // 更新task的color和taskname
    [mirrorDict removeObjectForKey:task.taskName];
    [taskDict setValue:[UIColor stringFromColor:newColor] forKey:@"color"];
    // 保存更新好的task到本地
    [mirrorDict setValue:taskDict forKey:newName];
    // 将mirror dict存回本地
    [[NSUserDefaults standardUserDefaults] setValue:mirrorDict forKey:kMirrorDict];
}

- (void)startTask:(MirrorDataModel *)task
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [[[NSUserDefaults standardUserDefaults] valueForKey:kMirrorDict] mutableCopy];
    // 取出这个task以便作修改
    NSMutableDictionary *taskDict = [mirrorDict[task.taskName] mutableCopy];
    // 更新task的ongoing状态
    [taskDict setValue:@(YES) forKey:@"is_ongoing"];
    // 给task创建一个新的period，并给出这个period的起始时间（now）
    NSMutableArray *allPeriods = [[NSMutableArray alloc] initWithArray:taskDict[@"periods"]];
    NSMutableArray *newPeriod = [[NSMutableArray alloc] initWithArray:@[@((long)[[NSDate now] timeIntervalSince1970])]];
    [allPeriods addObject:newPeriod];
    [taskDict setValue:allPeriods forKey:@"periods"];
    // 保存更新好的task到本地
    [mirrorDict setValue:taskDict forKey:task.taskName];
    // 将mirror dict存回本地
    [[NSUserDefaults standardUserDefaults] setValue:mirrorDict forKey:kMirrorDict];
}

- (void)stopTask:(MirrorDataModel *)task
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [[[NSUserDefaults standardUserDefaults] valueForKey:kMirrorDict] mutableCopy];
    // 取出这个task以便作修改
    NSMutableDictionary *taskDict = [mirrorDict[task.taskName] mutableCopy];
    // 更新task的ongoing状态
    [taskDict setValue:@(NO) forKey:@"is_ongoing"];
    // 将最后一个period取出来，给它一个结束时间（now）
    NSMutableArray *allPeriods =  [[NSMutableArray alloc] initWithArray:taskDict[@"periods"]];
    if (allPeriods.count > 0) {
        NSMutableArray *lastPeriod = [[NSMutableArray alloc] initWithArray:allPeriods[allPeriods.count-1]];
        long end = [[NSDate now] timeIntervalSince1970];
        long start = [lastPeriod[0] longValue];
        long length = end - start;
        if (lastPeriod.count == 1 &&  length > 10) { // 长度为10秒以上开始记录
            [lastPeriod addObject:@((long)[[NSDate now] timeIntervalSince1970])];
            allPeriods[allPeriods.count-1] = lastPeriod;
        } else { // 错误格式或者10秒以下，丢弃这个task
            [allPeriods removeObject:lastPeriod];
        }
        [taskDict setValue:allPeriods forKey:@"periods"];
    }
    // 保存更新好的task到本地
    [mirrorDict setValue:taskDict forKey:task.taskName];
    // 将mirror dict存回本地
    [[NSUserDefaults standardUserDefaults] setValue:mirrorDict forKey:kMirrorDict];
}

- (void)stopAllTasks
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [[[NSUserDefaults standardUserDefaults] valueForKey:kMirrorDict] mutableCopy];
    // 更新tasks的ongoing状态
    for (id key in mirrorDict.allKeys) {
        NSMutableDictionary *taskDict = [mirrorDict[key] mutableCopy];
        [taskDict setValue:@(NO) forKey:@"is_ongoing"];
        [mirrorDict setValue:taskDict forKey:key];
    }
    // 将mirror dict存回本地
    [[NSUserDefaults standardUserDefaults] setValue:mirrorDict forKey:kMirrorDict];
}

- (void)addTask:(MirrorDataModel *)task onDate:(NSString *)date time:(NSInteger)seconds
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [[[NSUserDefaults standardUserDefaults] valueForKey:kMirrorDict] mutableCopy];
    // 更新task时间
    NSInteger oldTime = [mirrorDict[task.taskName][@"periods"][date] integerValue];
    NSInteger newTime = oldTime + seconds;
    [mirrorDict[task.taskName][@"periods"] setValue:@(newTime) forKey:date];
    // 将mirror dict存回本地
    [[NSUserDefaults standardUserDefaults] setValue:mirrorDict forKey:kMirrorDict];
}

- (TaskNameExistsType)taskNameExists:(NSString *)newTaskName
{
    NSMutableDictionary *mirrorDict = [[[NSUserDefaults standardUserDefaults] valueForKey:kMirrorDict] mutableCopy];
    for (id key in mirrorDict.allKeys) {
        if ([key isEqualToString:newTaskName]) {
            if ([mirrorDict[key][@"is_archived"] boolValue]) {
                return TaskNameExistsTypeExistsInArchivedTasks;
            } else {
                return TaskNameExistsTypeExistsInCurrentTasks;
            }
        }
    }
    return TaskNameExistsTypeValid;
}

- (long)getTimeFromTask:(MirrorDataModel *)task OnDate:(NSString *)date
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [[[NSUserDefaults standardUserDefaults] valueForKey:kMirrorDict] mutableCopy];
    // 通过task和date拿到时间
    return [[mirrorDict[task.taskName][@"periods"] valueForKey:date defaultObject:@0] integerValue];
}

- (long)getTotalTimeFromTask:(MirrorDataModel *)task
{
    // 在本地取出task的data
    NSMutableDictionary *mirrorDict = [[[NSUserDefaults standardUserDefaults] valueForKey:kMirrorDict] mutableCopy];
    NSMutableDictionary *taskData = [NSMutableDictionary new];
    for (id key in mirrorDict.allKeys) {
        if ([[key stringValue] isEqualToString:task.taskName]) {
            taskData = mirrorDict[task.taskName][@"periods"];
            break;
        }
    }
    
    NSInteger time = 0;
    for (id key in taskData.allKeys) {
        time += [taskData[key] integerValue];
    }
    return time;
}

@end
