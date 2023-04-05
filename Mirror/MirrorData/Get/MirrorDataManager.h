//
//  MirrorDataManager.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import <Foundation/Foundation.h>
#import "MirrorDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MirrorDataManager : NSObject

+ (NSMutableArray<MirrorDataModel *> *)activatedTasksWithAddTask; // 所有没被archived的tasks，如果数量不足要加一个add task假model（TimeTrackerViewController专用）
+ (NSMutableArray<MirrorDataModel *> *)activatedTasks; // 所有没被archived的tasks
+ (NSMutableArray<MirrorDataModel *> *)archivedTasks; // 所有被archived了的tasks

@end

NS_ASSUME_NONNULL_END
