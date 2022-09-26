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

@property (nonatomic, strong) NSArray<TimeTrackerTaskModel *> *tasks;

@end

NS_ASSUME_NONNULL_END
