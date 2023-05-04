//
//  MirrorDataManager.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import "MirrorDataManager.h"
#import "MirrorMacro.h"
#import "MirrorStorage.h"
#import "MirrorTool.h"

@implementation MirrorDataManager

#pragma mark - Get tasks

+ (NSMutableArray<MirrorTaskModel *> *)activatedTasksWithAddTask
{
    NSMutableArray<MirrorTaskModel *> *activatedTasksWithAddTask = [MirrorDataManager activatedTasks];
    MirrorTaskModel *fakeModel = [[MirrorTaskModel alloc] initWithTitle:nil createdTime:nil order:nil colorType:nil isArchived:nil periods:nil isAddTask:YES];
    [activatedTasksWithAddTask addObject:fakeModel];
    return activatedTasksWithAddTask;
}

+ (NSMutableArray<MirrorTaskModel *> *)activatedTasks
{
    NSMutableArray<MirrorTaskModel *> *activatedTasks = [NSMutableArray new];
    NSMutableArray<MirrorTaskModel *> *allTasks = [MirrorDataManager allTasks];
    for (int i=0; i<allTasks.count; i++) {
        MirrorTaskModel *model = allTasks[i];
        if (!model.isArchived) {
            [activatedTasks addObject:model];
        }
    }
    return activatedTasks;
}

+ (NSMutableArray<MirrorTaskModel *> *)archivedTasks
{
    NSMutableArray<MirrorTaskModel *> *archivedTasks = [NSMutableArray new];
    NSMutableArray<MirrorTaskModel *> *allTasks = [MirrorDataManager allTasks];
    for (int i=0; i<allTasks.count; i++) {
        MirrorTaskModel *model = allTasks[i];
        if (model.isArchived) {
            [archivedTasks addObject:model];
        }
    }
    return archivedTasks;
}

+ (NSMutableArray<MirrorTaskModel *> *)allTasks // Dictionaries by definition are unordered. So I used an array to do the trick
{
    // 把所有task加到一个array里
    NSMutableArray<MirrorTaskModel *> *allTasks = [NSMutableArray new];
    NSMutableDictionary *dict = [MirrorStorage retriveMirrorData];
    for (id taskName in dict.allKeys) {
        MirrorTaskModel *task = dict[taskName];
        [allTasks addObject:task];
    }
    // sort
    NSSortDescriptor *sdSortDate = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    allTasks = [NSMutableArray arrayWithArray:[allTasks sortedArrayUsingDescriptors:@[sdSortDate]]];
    return allTasks;
}

+ (NSMutableArray<MirrorTaskModel *> *)getDataWithStart:(long)startTime end:(long)endTime
{
    /* 所有的情况：
                        _________________________________
               _____   |   _____      _____      _____   |   _____
            __|_____|__|__|_____|____|_____|____|_____|__|__|_____|__
                             !                     !
                         start time             end time
    
    */
    BOOL printDetailsToDebug = NO; // debug用
    NSMutableArray<MirrorTaskModel *> *targetTasks = [NSMutableArray<MirrorTaskModel *> new];
    NSMutableArray<MirrorTaskModel *> *allTasks = [MirrorDataManager allTasks];
    if (printDetailsToDebug) NSLog(@"数据库里的task个数 %@", @(allTasks.count));
    for (int taskIndex=0; taskIndex<allTasks.count; taskIndex++) {
        MirrorTaskModel *task = allTasks[taskIndex];
        MirrorTaskModel *targetTask = [[MirrorTaskModel alloc] initWithTitle:task.taskName createdTime:task.createdTime order:task.priority colorType:task.color isArchived:task.isArchived periods:[NSMutableArray new] isAddTask:NO];
        BOOL targetTaskIsEmpty = YES;
        for (int periodIndex=0; periodIndex<task.periods.count; periodIndex++) {
            NSMutableArray *period = task.periods[periodIndex];
            if (printDetailsToDebug) {
                NSLog(@"task%@的第%@个period，[%@,%@]，选取的时间段[%@,%@]",[UIColor getEmoji:task.color], @(periodIndex), period.count>0 ? [MirrorTool timeFromTimestamp:[period[0] longValue] printTimeStamp:NO]: @"?", period.count>1 ? [MirrorTool timeFromTimestamp:[period[1] longValue] printTimeStamp:NO] : @"?", [MirrorTool timeFromTimestamp:startTime printTimeStamp:NO], [MirrorTool timeFromTimestamp:endTime printTimeStamp:NO]);
            }
            if (period.count != 2) {
                if (printDetailsToDebug) NSLog(@"✖️正在计时中，不管");
                continue;
            }
            // [1] < starttime
            else if ([period[1] longValue] < startTime) {
                if (printDetailsToDebug) NSLog(@"✖️完整地发生在start time之前，不管");
            }
            // [0]<=starttime, startime<=[1]<=endtime
            else if ([period[0] longValue] <= startTime &&  startTime <= [period[1] longValue] && [period[1] longValue] <= endTime ) {
                if (printDetailsToDebug) NSLog(@"✔️跨越了start time，取后半段");
                targetTaskIsEmpty = NO;
                [targetTask.periods addObject:[@[@(startTime), period[1]] mutableCopy]];
            }
            // starttime<=[0], [1]<=endtime
            else if (startTime <= [period[0] longValue] && [period[1] longValue] <= endTime) {
                if (printDetailsToDebug) NSLog(@"✔️完整地发生在start time和end time中间");
                targetTaskIsEmpty = NO;
                [targetTask.periods addObject:[@[period[0], period[1]] mutableCopy]];
            }
            // starttime<=[0]<=endtime, endtime<=[1]
            else if (startTime <= [period[0] longValue] && [period[0] longValue] <= endTime && endTime <= [period[1] longValue]) {
                if (printDetailsToDebug) NSLog(@"✔️跨越了end time，取前半段");
                targetTaskIsEmpty = NO;// 跨越了end time，取前半段
                [targetTask.periods addObject:[@[ period[0], @(endTime)] mutableCopy]];
            }
            // endtime < [0]
            else if (endTime < [period[0] longValue]) {
                if (printDetailsToDebug) NSLog(@"✖️完整地发生在end time之后，不管");
                // 完整地发生在end time之后，不管
            }
            // [0]<=starttime || endtime <=[1]
            else if ([period[0] longValue] <= startTime && endTime <= [period[1] longValue]) {
                if (printDetailsToDebug) NSLog(@"✖️囊括了整个starttime到endtime");
                targetTaskIsEmpty = NO;// 囊括了整个starttime到endtime
                [targetTask.periods addObject:[@[@(startTime), @(endTime)] mutableCopy]];
            }
            
        }
        if (!targetTaskIsEmpty) {
            if (printDetailsToDebug) NSLog(@"这个task%@里有目标时间段内的periods，已经取出", [UIColor getEmoji:task.color]);
            [targetTasks addObject:targetTask];
        }
    }
    return targetTasks;
}

@end
