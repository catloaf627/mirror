//
//  EditTaskViewController.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/29.
//

#import <UIKit/UIKit.h>
#import "TimeTrackerTaskModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EditTaskProtocol <NSObject>

- (void)updateTasks;
- (void)deleteTask:(TimeTrackerTaskModel *)model;
- (void)archiveTask:(TimeTrackerTaskModel *)model;

@end

@interface EditTaskViewController : UIViewController

@property (nonatomic, strong) UIViewController<EditTaskProtocol> *delegate;
- (instancetype)initWithTasks:(TimeTrackerTaskModel *)task;

@end

NS_ASSUME_NONNULL_END
