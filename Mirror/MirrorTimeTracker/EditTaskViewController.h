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

@end

@interface EditTaskViewController : UIViewController

@property (nonatomic, strong) UIViewController<EditTaskProtocol> *delegate;
- (instancetype)initWithTasks:(NSMutableArray<TimeTrackerTaskModel *> *)tasks index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
