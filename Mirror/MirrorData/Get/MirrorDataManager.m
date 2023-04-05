//
//  MirrorDataManager.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import "MirrorDataManager.h"
#import "MirrorMacro.h"

@implementation MirrorDataManager

+ (NSMutableArray<MirrorDataModel *> *)activatedTasksWithAddTask
{
    NSMutableArray<MirrorDataModel *> *activatedTasksWithAddTask = [MirrorDataManager activatedTasks];
    if (activatedTasksWithAddTask.count < kMaxTaskNum) {
        //cell数量不足的时候必加add task cell
        [activatedTasksWithAddTask addObject:[[MirrorDataModel alloc]initWithTitle:nil createdTime:nil colorType:nil isArchived:nil isOngoing:nil isAddTask:YES]];
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

#pragma mark - Private methods

+ (NSMutableArray<MirrorDataModel *> *)allTasks
{
    NSMutableArray<MirrorDataModel *> *allTasks = [NSMutableArray new];
    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] valueForKey:@"mirror_dict"];
    for (id taskName in dict.allKeys) {
        MirrorColorType color = [UIColor colorFromString:dict[taskName][@"color"]];
        BOOL isArchived = [dict[taskName][@"is_archived"] boolValue];
        BOOL isOngoing = [dict[taskName][@"is_ongoing"] boolValue];
        long createdTime = [dict[taskName][@"created_time"] longValue];
        MirrorDataModel *model = [[MirrorDataModel alloc]initWithTitle:taskName createdTime:createdTime colorType:color isArchived:isArchived isOngoing:isOngoing isAddTask:NO];
        [allTasks addObject:model];
    }
    // sort
    NSSortDescriptor *sdSortDate = [NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:YES];
    allTasks = [NSMutableArray arrayWithArray:[allTasks sortedArrayUsingDescriptors:@[sdSortDate]]];
    return allTasks;
}

@end
