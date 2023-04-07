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
    NSMutableDictionary *mirrorDict = [self retriveMirrorData];
    // 新增一个task
    [mirrorDict setValue:task forKey:task.taskName];
    // 将mirror dict存回本地
    [self saveMirrorData:mirrorDict];
}

- (void)deleteTask:(NSString *)taskName
{
    // 在本地取出词典
    NSMutableDictionary *mirrorDict = [self retriveMirrorData];
    // 通过taskname删除task
    [mirrorDict removeObjectForKey:taskName];
    // 将mirror dict存回本地
    [self saveMirrorData:mirrorDict];
}

- (void)archiveTask:(NSString *)taskName
{
    [self stopTask:taskName completion:nil]; // archive导致的停止计时，不展示完成的toast
    // 在本地取出task
    NSMutableDictionary *mirrorDict = [self retriveMirrorData];
    // 取出这个task以便作修改
    MirrorDataModel *task = mirrorDict[taskName];
    // stop task first
    // 更新task的archive状态
    task.isArchived = YES;
    // 保存更新好的task到本地
    [mirrorDict setValue:task forKey:taskName];
    // 将mirror dict存回本地
    [self saveMirrorData:mirrorDict];
}

- (void)editTask:(NSString *)oldName color:(MirrorColorType)newColor name:(NSString *)newName
{
    // 在本地取出task
    NSMutableDictionary *mirrorDict = [self retriveMirrorData];
    // 取出这个task以便作修改
    MirrorDataModel *task = mirrorDict[oldName];
    // 更新task的color和taskname
    [mirrorDict removeObjectForKey:oldName];
    task.color = newColor;
    // 保存更新好的task到本地
    [mirrorDict setValue:task forKey:newName];
    // 将mirror dict存回本地
    [self saveMirrorData:mirrorDict];
}

- (void)startTask:(NSString *)taskName
{
    // 在本地取出task
    NSMutableDictionary *mirrorDict = [self retriveMirrorData];
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
    [self saveMirrorData:mirrorDict];
}

- (void)stopTask:(NSString *)taskName completion:(void (^)(NSString *hint))completion
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [self retriveMirrorData];
    // 取出这个task以便作修改
    MirrorDataModel *task = mirrorDict[taskName];
    // 将最后一个period取出来，给它一个结束时间（now）
    NSMutableArray *allPeriods = [[NSMutableArray alloc] initWithArray:task.periods];
    if (allPeriods.count > 0) {
        NSMutableArray *lastPeriod = [[NSMutableArray alloc] initWithArray:allPeriods[allPeriods.count-1]];
        long start = [lastPeriod[0] longValue];
        long end = [[NSDate now] timeIntervalSince1970];
        long length = end - start;
        NSLog(@"start %ld, end %ld, length %ld", start, end, length);
        if (lastPeriod.count == 1 &&  length > 10) { // 长度为10秒以上开始记录
            [lastPeriod addObject:@(round([[NSDate now] timeIntervalSince1970]))];
            allPeriods[allPeriods.count-1] = lastPeriod;
            [self p_callCompletion:completion taskName:taskName withTimeInterval:length]; // 需要走回调弹toast
        } else { // 错误格式或者10秒以下，丢弃这个task
            [allPeriods removeLastObject];
        }
        task.periods = allPeriods;
    }
    // 保存更新好的task到本地
    [mirrorDict setValue:task forKey:taskName];
    // 将mirror dict存回本地
    [self saveMirrorData:mirrorDict];

}

- (void)stopAllTasksExcept:(NSString *)exceptTaskName completion:(void (^)(NSString *hint))completion
{
    // 在本地取出mirror dict
    NSMutableDictionary *mirrorDict = [self retriveMirrorData];
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
        
        // 将最后一个period取出来，给它一个结束时间（now）
        NSMutableArray *allPeriods = [[NSMutableArray alloc] initWithArray:task.periods];
        if (allPeriods.count > 0) {
            NSMutableArray *lastPeriod = [[NSMutableArray alloc] initWithArray:allPeriods[allPeriods.count-1]];
            long end = [[NSDate now] timeIntervalSince1970];
            long start = [lastPeriod[0] longValue];
            long length = end - start;
            if (lastPeriod.count == 1 &&  length > 10) { // 长度为10秒以上开始记录
                [lastPeriod addObject:@(round([[NSDate now] timeIntervalSince1970]))];
                allPeriods[allPeriods.count-1] = lastPeriod;
                [self p_callCompletion:completion taskName:taskName withTimeInterval:length]; // 需要走回调弹toast，注意这里结束的是task.taskName，而不是except传进来的taskName
            } else { // 错误格式或者10秒以下，丢弃这个task
                [allPeriods removeLastObject];
            }
            task.periods = allPeriods;
        }
        // 保存更新好的task到本地
        [mirrorDict setValue:task forKey:taskName];
    }
    // 将mirror dict存回本地
    [self saveMirrorData:mirrorDict];
}

- (void)p_callCompletion:(void (^)(NSString *hint))completion taskName:(NSString *)taskName withTimeInterval:(NSTimeInterval)timeInterval
{
    NSString *hintInfo = [MirrorLanguage mirror_stringWithKey:@"task_has_been_done" with1Placeholder:taskName with2Placeholder:[[NSDateComponentsFormatter new] stringFromTimeInterval:timeInterval]];
    if (completion) {
        completion(hintInfo);
    }
}

- (TaskNameExistsType)taskNameExists:(NSString *)newTaskName
{
    NSMutableDictionary *mirrorDict = [self retriveMirrorData];
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

- (void)saveMirrorData:(NSMutableDictionary *)mirrorDict // 归档
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mirrorDict requiringSecureCoding:YES error:nil];
    [[NSUserDefaults standardUserDefaults] setValue:data forKey:kMirrorDict];
    // Log
    [self printData:mirrorDict info:@"------saving user data------"];
}

- (NSMutableDictionary *)retriveMirrorData // 解档
{
    NSData *storedEncodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kMirrorDict];
    NSMutableDictionary *mirrorDict = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[MirrorDataModel.class,NSMutableDictionary.class, NSMutableArray.class]] fromData:storedEncodedObject error:nil];
    // Log
    [self printData:mirrorDict info:@"------retriving user data------"];
    return mirrorDict ?: [NSMutableDictionary new];
}

- (void)printData:(NSMutableDictionary *)mirrorDict info:(NSString *)info
{
    NSLog(@"%@", info ?: @"");
    for (id taskName in mirrorDict.allKeys) {
        MirrorDataModel *task = mirrorDict[taskName];
        NSString *tag = @"";
        tag = [tag stringByAppendingString:task.isArchived ? @"[":@" "];
        if ([[UIColor stringFromColor:task.color] isEqualToString:[UIColor stringFromColor:MirrorColorTypeCellPink]]) {
            tag = [tag stringByAppendingString:@"🌸"];
        } else if ([[UIColor stringFromColor:task.color] isEqualToString:[UIColor stringFromColor:MirrorColorTypeCellOrange]]) {
            tag = [tag stringByAppendingString:@"🍊"];
        } else if ([[UIColor stringFromColor:task.color] isEqualToString:[UIColor stringFromColor:MirrorColorTypeCellYellow]]) {
            tag = [tag stringByAppendingString:@"🍋"];
        } else if ([[UIColor stringFromColor:task.color] isEqualToString:[UIColor stringFromColor:MirrorColorTypeCellGreen]]) {
            tag = [tag stringByAppendingString:@"🪀"];
        } else if ([[UIColor stringFromColor:task.color] isEqualToString:[UIColor stringFromColor:MirrorColorTypeCellTeal]]) {
            tag = [tag stringByAppendingString:@"🧼"];
        } else if ([[UIColor stringFromColor:task.color] isEqualToString:[UIColor stringFromColor:MirrorColorTypeCellBlue]]) {
            tag = [tag stringByAppendingString:@"🐟"];
        } else if ([[UIColor stringFromColor:task.color] isEqualToString:[UIColor stringFromColor:MirrorColorTypeCellBlue]]) {
            tag = [tag stringByAppendingString:@"👾"];
        }
        tag = [tag stringByAppendingString:task.isArchived ? @"]":@" "];
        NSLog(@"%@: %@, created at %ld",tag, task.taskName, task.createdTime);
        for (int i=0; i<task.periods.count; i++) {
            if (task.periods[i].count == 1) {
                NSLog(@"[%ld, ...], ", [task.periods[i][0] longValue]);
            }
            if (task.periods[i].count == 2) {
                NSLog(@"[%ld, %ld], ", [task.periods[i][0] longValue], [task.periods[i][1] longValue]);
            }
        }
    }
}

@end
