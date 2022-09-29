//
//  EditTaskViewController.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/29.
//

#import <UIKit/UIKit.h>
#import "TimeTrackerTaskModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EditTaskViewController : UIViewController

- (instancetype)initWithTasks:(NSMutableArray<TimeTrackerTaskModel *> *)tasks index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
