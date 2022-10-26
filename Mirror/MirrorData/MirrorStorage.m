//
//  MirrorStorage.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/10/24.
//

#import "MirrorStorage.h"
#import "NSMutableDictionary+MirrorDictionary.h"

static NSString *const kMirrorDict = @"MirrorDict";

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

- (void)createTask:(TimeTrackerTaskModel *)task
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [[[NSUserDefaults standardUserDefaults] valueForKey:kMirrorDict] mutableCopy] ?: [NSMutableDictionary new];
    // 新增一个task
    [mirrorDict setValue: @{@"color": [UIColor stringFromColor:task.color], @"isArchived" : @(task.isArchived), @"isOngoing":@(NO),  @"data":[NSMutableDictionary new]} forKey:task.taskName];
    // 将mirror dict存回本地
    [[NSUserDefaults standardUserDefaults] setValue:mirrorDict forKey:kMirrorDict];
}

- (void)deleteTask:(TimeTrackerTaskModel *)task
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [[[NSUserDefaults standardUserDefaults] valueForKey:kMirrorDict] mutableCopy];
    // 通过taskname删除task
    [mirrorDict removeObjectForKey:task.taskName];
    // 将mirror dict存回本地
    [[NSUserDefaults standardUserDefaults] setValue:mirrorDict forKey:kMirrorDict];
}

- (void)archiveTask:(TimeTrackerTaskModel *)task
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [[[NSUserDefaults standardUserDefaults] valueForKey:kMirrorDict] mutableCopy];
    // 更新task的archive状态
    [mirrorDict[task.taskName] setValue:@(YES) forKey:@"isArchived"];
    // 将mirror dict存回本地
    [[NSUserDefaults standardUserDefaults] setValue:mirrorDict forKey:kMirrorDict];
}

- (void)editTask:(TimeTrackerTaskModel *)task fromName:(NSString *)oldTaskName;
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [[[NSUserDefaults standardUserDefaults] valueForKey:kMirrorDict] mutableCopy];
    // 更新task的color
    [mirrorDict[oldTaskName] setValue:[UIColor stringFromColor:task.color] forKey:@"color"];
    // 更新task的name
    NSMutableDictionary *value = mirrorDict[oldTaskName];
    [mirrorDict removeObjectForKey:oldTaskName];
    [mirrorDict setValue:value forKey:task.taskName];
    // 将mirror dict存回本地
    [[NSUserDefaults standardUserDefaults] setValue:mirrorDict forKey:kMirrorDict];
}

- (void)addTask:(TimeTrackerTaskModel *)task onDate:(NSString *)date time:(NSInteger)seconds
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [[[NSUserDefaults standardUserDefaults] valueForKey:kMirrorDict] mutableCopy];
    // 更新task时间
    NSInteger oldTime = [mirrorDict[task.taskName][@"data"][date] integerValue];
    NSInteger newTime = oldTime + seconds;
    [mirrorDict[task.taskName][@"data"] setValue:@(newTime) forKey:date];
    // 将mirror dict存回本地
    [[NSUserDefaults standardUserDefaults] setValue:mirrorDict forKey:kMirrorDict];
}

- (NSInteger)getTimeFromTask:(TimeTrackerTaskModel *)task OnDate:(NSString *)date
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [[[NSUserDefaults standardUserDefaults] valueForKey:kMirrorDict] mutableCopy];
    // 通过task和date拿到时间
    return [[mirrorDict[task.taskName][@"data"] valueForKey:date defaultObject:@0] integerValue];
}

- (NSInteger)getTotalTimeFromTask:(TimeTrackerTaskModel *)task
{
    // 在本地取出task的data
    NSMutableDictionary *mirrorDict = [[[NSUserDefaults standardUserDefaults] valueForKey:kMirrorDict] mutableCopy];
    NSMutableDictionary *taskData = [NSMutableDictionary new];
    for (id key in mirrorDict.allKeys) {
        if ([[key stringValue] isEqualToString:task.taskName]) {
            taskData = mirrorDict[task.taskName][@"data"];
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
