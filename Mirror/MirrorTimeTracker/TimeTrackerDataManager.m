//
//  TimeTrackerDataManager.m
//  Mirror
//
//  Created by wangyuqing on 2022/9/26.
//

#import "TimeTrackerDataManager.h"
#import "MirrorMacro.h"

@implementation TimeTrackerDataManager

- (NSMutableArray<TimeTrackerTaskModel *> *)tasks
{
    _tasks = [NSMutableArray new];
    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] valueForKey:@"MirrorDict"];
    for (id taskName in dict.allKeys) {
        MirrorColorType color = [UIColor colorFromString:dict[taskName][@"color"]];
        BOOL isArchived = [dict[taskName][@"isArchived"] boolValue];
        BOOL isOngoing = [dict[taskName][@"isOngoing"] boolValue];
        TimeTrackerTaskModel *model = [[TimeTrackerTaskModel alloc]initWithTitle:taskName colorType:color isArchived:isArchived isOngoing:isOngoing isAddTask:NO];
        [_tasks addObject:model];
    }
    if (_tasks.count < kMaxTaskNum) {
        //cell数量不足的时候必加add task cell
        [_tasks addObject:[[TimeTrackerTaskModel alloc]initWithTitle:nil colorType:nil isArchived:nil isOngoing:nil isAddTask:YES]];
    }
    return _tasks;
}

@end
