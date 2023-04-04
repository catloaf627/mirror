//
//  TimeTrackerDataManager.h
//  Mirror
//
//  Created by wangyuqing on 2022/9/26.
//

#import <Foundation/Foundation.h>
#import "TimeTrackerTaskModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimeTrackerDataManager : NSObject

// TimeTrackerViewController专用
@property (nonatomic, strong) NSMutableArray<TimeTrackerTaskModel *> *tasks;
// DataViewController专用
@property (nonatomic, strong) NSMutableArray<TimeTrackerTaskModel *> *activatedTasks;
@property (nonatomic, strong) NSMutableArray<TimeTrackerTaskModel *> *archivedTasks;

@end

NS_ASSUME_NONNULL_END
