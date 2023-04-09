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

+ (NSMutableArray<MirrorDataModel *> *)todayTasks
{
    NSMutableArray<MirrorDataModel *> *todayTasks = [NSMutableArray<MirrorDataModel *> new];
    NSMutableArray<MirrorDataModel *> *allTasks = [MirrorDataManager allTasks];
    long today = [MirrorStorage startedTimeToday];
    for (int taskIndex=0; taskIndex<allTasks.count; taskIndex++) {
        MirrorDataModel *task = allTasks[taskIndex];
        MirrorDataModel *todayTask = [[MirrorDataModel alloc] initWithTitle:task.taskName createdTime:task.createdTime colorType:task.color isArchived:task.isArchived periods:[NSMutableArray new] isAddTask:NO];
        BOOL todayTaskIsEmpty = YES;
        for (int periodIndex=0; periodIndex<task.periods.count; periodIndex++) {
            NSMutableArray *period = task.periods[periodIndex];
            if (period.count != 2) {
                // 正在计时中，不管
            } if ([period[1] longValue] < today) {
                // 完整地发生在今天之前，不管
            } else if ([period[0] longValue] < today && [period[1] longValue] > today) {
                todayTaskIsEmpty = NO;// 跨越了今天0点，取后半段
                [todayTask.periods addObject:[@[@(today), period[1]] mutableCopy]];
            } else if ([period[0] longValue] > today) {
                todayTaskIsEmpty = NO;// 完整地发生在今天
                [todayTask.periods addObject:[@[period[0], period[1]] mutableCopy]];
            }
            // 因为now最多取到当前，所以不存在“发生在明天”的period
        }
        if (!todayTaskIsEmpty) {
            [todayTasks addObject:todayTask];
            [MirrorStorage printTask:todayTask info:@"today task"];
        }
    }
    return todayTasks;
}

+ (NSMutableArray<MirrorDataModel *> *)weekTasks
{
    NSMutableArray<MirrorDataModel *> *weekTasks = [NSMutableArray<MirrorDataModel *> new];
    NSMutableArray<MirrorDataModel *> *allTasks = [MirrorDataManager allTasks];
    long week = [MirrorStorage startedTimeThisWeek];
    for (int taskIndex=0; taskIndex<allTasks.count; taskIndex++) {
        MirrorDataModel *task = allTasks[taskIndex];
        MirrorDataModel *weekTask = [[MirrorDataModel alloc] initWithTitle:task.taskName createdTime:task.createdTime colorType:task.color isArchived:task.isArchived periods:[NSMutableArray new] isAddTask:NO];
        BOOL weekTaskIsEmpty = YES;
        for (int periodIndex=0; periodIndex<task.periods.count; periodIndex++) {
            NSMutableArray *period = task.periods[periodIndex];
            if (period.count != 2) {
                // 正在计时中，不管
            } if ([period[1] longValue] < week) {
                // 完整地发生在本周之前，不管
            } else if ([period[0] longValue] < week && [period[1] longValue] > week) {
                weekTaskIsEmpty = NO;// 跨越了本周0点，取后半段
                [weekTask.periods addObject:[@[@(week), period[1]] mutableCopy]];
            } else if ([period[0] longValue] > week) {
                weekTaskIsEmpty = NO;// 完整地发生在这周
                [weekTask.periods addObject:[@[period[0], period[1]] mutableCopy]];
            }
            // 因为now最多取到当前，所以不存在“发生在下周”的period
        }
        if (!weekTaskIsEmpty) {
            [weekTasks addObject:weekTask];
            [MirrorStorage printTask:weekTask info:@"week task"];
        }
    }
    return weekTasks;
}

+ (NSMutableArray<MirrorDataModel *> *)monthTasks
{
    NSMutableArray<MirrorDataModel *> *monthTasks = [NSMutableArray<MirrorDataModel *> new];
    NSMutableArray<MirrorDataModel *> *allTasks = [MirrorDataManager allTasks];
    long month = [MirrorStorage startedTimeThisMonth];
    for (int taskIndex=0; taskIndex<allTasks.count; taskIndex++) {
        MirrorDataModel *task = allTasks[taskIndex];
        MirrorDataModel *monthTask = [[MirrorDataModel alloc] initWithTitle:task.taskName createdTime:task.createdTime colorType:task.color isArchived:task.isArchived periods:[NSMutableArray new] isAddTask:NO];
        BOOL monthTaskIsEmpty = YES;
        for (int periodIndex=0; periodIndex<task.periods.count; periodIndex++) {
            NSMutableArray *period = task.periods[periodIndex];
            if (period.count != 2) {
                // 正在计时中，不管
            } if ([period[1] longValue] < month) {
                // 完整地发生在本月之前，不管
            } else if ([period[0] longValue] < month && [period[1] longValue] > month) {
                monthTaskIsEmpty = NO;// 跨越了本月0点，取后半段
                [monthTask.periods addObject:[@[@(month), period[1]] mutableCopy]];
            } else if ([period[0] longValue] > month) {
                monthTaskIsEmpty = NO;// 完整地发生在本月
                [monthTask.periods addObject:[@[period[0], period[1]] mutableCopy]];
            }
            // 因为now最多取到当前，所以不存在“发生在下月”的period
        }
        if (!monthTaskIsEmpty) {
            [monthTasks addObject:monthTask];
            [MirrorStorage printTask:monthTask info:@"month task"];
        }
    }
    return monthTasks;
}

+ (NSMutableArray<MirrorDataModel *> *)yearTasks
{
    NSMutableArray<MirrorDataModel *> *yearTasks = [NSMutableArray<MirrorDataModel *> new];
    NSMutableArray<MirrorDataModel *> *allTasks = [MirrorDataManager allTasks];
    long year = [MirrorStorage startedTimeThisYear];
    for (int taskIndex=0; taskIndex<allTasks.count; taskIndex++) {
        MirrorDataModel *task = allTasks[taskIndex];
        MirrorDataModel *yearTask = [[MirrorDataModel alloc] initWithTitle:task.taskName createdTime:task.createdTime colorType:task.color isArchived:task.isArchived periods:[NSMutableArray new] isAddTask:NO];
        BOOL yearTaskIsEmpty = YES;
        for (int periodIndex=0; periodIndex<task.periods.count; periodIndex++) {
            NSMutableArray *period = task.periods[periodIndex];
            if (period.count != 2) {
                // 正在计时中，不管
            } if ([period[1] longValue] < year) {
                // 完整地发生在今年之前，不管
            } else if ([period[0] longValue] < year && [period[1] longValue] > year) {
                yearTaskIsEmpty = NO;// 跨越了今年0点，取后半段
                [yearTask.periods addObject:[@[@(year), period[1]] mutableCopy]];
            } else if ([period[0] longValue] > year) {
                yearTaskIsEmpty = NO;// 完整地发生在今年
                [yearTask.periods addObject:[@[period[0], period[1]] mutableCopy]];
            }
            // 因为now最多取到当前，所以不存在“发生在明年”的period
        }
        if (!yearTaskIsEmpty) {
            [yearTasks addObject:yearTask];
            [MirrorStorage printTask:yearTask info:@"year task"];
        }
    }
    return yearTasks;
}


#pragma mark - Private methods

+ (NSMutableArray<MirrorDataModel *> *)allTasks // Dictionaries by definition are unordered. So I used an array to do the trick
{
    // 把所有task加到一个array里
    NSMutableArray<MirrorDataModel *> *allTasks = [NSMutableArray new];
    NSMutableDictionary *dict = [MirrorStorage retriveMirrorData];
    for (id taskName in dict.allKeys) {
        MirrorDataModel *task = dict[taskName];
        [allTasks addObject:task];
    }
    // sort
    NSSortDescriptor *sdSortDate = [NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:YES];
    allTasks = [NSMutableArray arrayWithArray:[allTasks sortedArrayUsingDescriptors:@[sdSortDate]]];
    return allTasks;
}

@end
