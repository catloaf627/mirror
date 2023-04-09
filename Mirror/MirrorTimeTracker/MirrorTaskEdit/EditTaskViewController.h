//
//  EditTaskViewController.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/29.
//

#import <UIKit/UIKit.h>
#import "MirrorDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DismissEditSheetProtocol <NSObject>

@end

@interface EditTaskViewController : UIViewController

@property (nonatomic, strong) UIViewController<DismissEditSheetProtocol> *delegate;
- (instancetype)initWithTasks:(MirrorDataModel *)task;

@end

NS_ASSUME_NONNULL_END
