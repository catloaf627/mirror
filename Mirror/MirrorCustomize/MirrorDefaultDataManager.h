//
//  MirrorDefaultDataManager.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/27.
//

#import <Foundation/Foundation.h>
#import "TimeTrackerTaskModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MirrorDefaultDataManager : NSObject

+ (instancetype)sharedInstance;

- (NSMutableArray<TimeTrackerTaskModel *> *)mirrorDefaultTimeTrackerData;

@end

NS_ASSUME_NONNULL_END
