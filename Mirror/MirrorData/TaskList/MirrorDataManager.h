//
//  MirrorDataManager.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import <Foundation/Foundation.h>
#import "MirrorDataModel.h"

NS_ASSUME_NONNULL_BEGIN

// ❗️❗️❗️这里的数据结构是数组结构，因为涉及到顺序的问题（与之相对的是MirrorStorage使用的是词典结构，因为主要用于寻找或者编辑某个task）
@interface MirrorDataManager : NSObject

+ (NSMutableArray<MirrorDataModel *> *)activatedTasksWithAddTask; // 所有没被archived的tasks，如果数量不足要加一个add task假model（TimeTrackerViewController专用）
+ (NSMutableArray<MirrorDataModel *> *)activatedTasks; // 所有没被archived的tasks
+ (NSMutableArray<MirrorDataModel *> *)archivedTasks; // 所有被archived了的tasks

+ (NSMutableArray<MirrorDataModel *> *)todayTasks;
+ (NSMutableArray<MirrorDataModel *> *)weekTasks;
+ (NSMutableArray<MirrorDataModel *> *)monthTasks;
+ (NSMutableArray<MirrorDataModel *> *)yearTasks;

+ (NSMutableArray<MirrorDataModel *> *)allTasks;

@end

NS_ASSUME_NONNULL_END
