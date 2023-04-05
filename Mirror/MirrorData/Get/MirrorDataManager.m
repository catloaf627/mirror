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
    NSMutableArray<MirrorDataModel *> *activatedTasksWithAddTask = [NSMutableArray new];
    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] valueForKey:@"mirror_dict"];
    for (id taskName in dict.allKeys) {
        MirrorColorType color = [UIColor colorFromString:dict[taskName][@"color"]];
        BOOL isArchived = [dict[taskName][@"is_archived"] boolValue];
        BOOL isOngoing = [dict[taskName][@"is_ongoing"] boolValue];
        if (!isArchived) {
            MirrorDataModel *model = [[MirrorDataModel alloc]initWithTitle:taskName colorType:color isArchived:isArchived isOngoing:isOngoing isAddTask:NO];
            [activatedTasksWithAddTask addObject:model];
        }
    }
    if (activatedTasksWithAddTask.count < kMaxTaskNum) {
        //cell数量不足的时候必加add task cell
        [activatedTasksWithAddTask addObject:[[MirrorDataModel alloc]initWithTitle:nil colorType:nil isArchived:nil isOngoing:nil isAddTask:YES]];
    }
    return activatedTasksWithAddTask;
}

+ (NSMutableArray<MirrorDataModel *> *)activatedTasks
{
    NSMutableArray<MirrorDataModel *> *activatedTasks = [NSMutableArray new];
    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] valueForKey:@"mirror_dict"];
    for (id taskName in dict.allKeys) {
        MirrorColorType color = [UIColor colorFromString:dict[taskName][@"color"]];
        BOOL isArchived = [dict[taskName][@"is_archived"] boolValue];
        BOOL isOngoing = [dict[taskName][@"is_ongoing"] boolValue];
        if (!isArchived) {
            MirrorDataModel *model = [[MirrorDataModel alloc]initWithTitle:taskName colorType:color isArchived:isArchived isOngoing:isOngoing isAddTask:NO];
            [activatedTasks addObject:model];
        }
    }
    return activatedTasks;
}

+ (NSMutableArray<MirrorDataModel *> *)archivedTasks
{
    NSMutableArray<MirrorDataModel *> *archivedTasks = [NSMutableArray new];
    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] valueForKey:@"mirror_dict"];
    for (id taskName in dict.allKeys) {
        MirrorColorType color = [UIColor colorFromString:dict[taskName][@"color"]];
        BOOL isArchived = [dict[taskName][@"is_archived"] boolValue];
        BOOL isOngoing = [dict[taskName][@"is_ongoing"] boolValue];
        if (isArchived) {
            MirrorDataModel *model = [[MirrorDataModel alloc]initWithTitle:taskName colorType:color isArchived:isArchived isOngoing:isOngoing isAddTask:NO];
            [archivedTasks addObject:model];
        }
    }
    return archivedTasks;
}


@end
