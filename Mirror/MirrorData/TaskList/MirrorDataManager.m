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
