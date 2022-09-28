//
//  TimeTrackerTaskModel.h
//  Mirror
//
//  Created by wangyuqing on 2022/9/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeTrackerTaskModel : NSObject

@property (nonatomic, assign) BOOL isAddTaskModel;
@property (nonatomic, strong) NSString *taskName;
@property (nonatomic, strong) NSString *timeInfo;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *pulseColor;

- (instancetype)initWithTitle:(NSString *)taskName color:(UIColor *)color pulseColor:(UIColor *)pulseColor isAddTask:(BOOL)isAddTaskModel;
- (void)didStartTask;
- (void)didStopTask;

@end

NS_ASSUME_NONNULL_END
