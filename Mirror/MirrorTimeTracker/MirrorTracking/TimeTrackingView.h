//
//  TimeTrackingView.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/10/22.
//

#import <UIKit/UIKit.h>
#import "MirrorDataModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol TimeTrackingViewProtocol <NSObject>

- (void)destroyTimeTrackingView;

@end

@interface TimeTrackingView : UIView

@property (nonatomic, weak) UIViewController<TimeTrackingViewProtocol> *delegate;

- (instancetype)initWithTaskName:(NSString *)taskName;
- (void)updateLabels;

@end

NS_ASSUME_NONNULL_END
