//
//  TimeTrackingView.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/10/22.
//

#import <UIKit/UIKit.h>
#import "TimeTrackerTaskModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol TimeTrackingViewProtocol <NSObject>

- (void)foldTimeTrackingView;

@end

@interface TimeTrackingView : UIView

@property (nonatomic, strong) UIViewController<TimeTrackingViewProtocol> *delegate;
- (instancetype)initWithTask:(TimeTrackerTaskModel *)taskModel;

@end

NS_ASSUME_NONNULL_END
