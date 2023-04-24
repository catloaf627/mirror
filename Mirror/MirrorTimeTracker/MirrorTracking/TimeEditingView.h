//
//  TimeEditingView.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TimeEditingViewProtocol <NSObject>

- (void)destroyTimeEditingView;

@end

@interface TimeEditingView : UIView

@property (nonatomic, strong) UIViewController<TimeEditingViewProtocol> *delegate;

- (instancetype)initWithTaskName:(NSString *)taskName;

@end

NS_ASSUME_NONNULL_END
