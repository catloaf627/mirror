//
//  AddTaskViewController.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/30.
//

#import <UIKit/UIKit.h>
#import "MirrorDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AddTaskProtocol <NSObject>

- (void)addNewTask:(MirrorDataModel *)newTask;

@end

@interface AddTaskViewController : UIViewController

@property (nonatomic, strong) UIViewController<AddTaskProtocol> *delegate;

@end

NS_ASSUME_NONNULL_END
