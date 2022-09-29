//
//  TimeTrackerTaskModel.m
//  Mirror
//
//  Created by wangyuqing on 2022/9/26.
//

#import "TimeTrackerTaskModel.h"
#import "MirrorLanguage.h"

@implementation TimeTrackerTaskModel

- (instancetype)initWithTitle:(NSString *)taskName color:(UIColor *)color pulseColor:(UIColor *)pulseColor isAddTask:(BOOL)isAddTaskModel
{
    self = [super init];
    if (self) {
        _taskName = taskName;
        _color = color;
        _pulseColor = pulseColor;
        _timeInfo = [MirrorLanguage mirror_stringWithKey:@"double_click_to_start"];
        _isAddTaskModel = isAddTaskModel;
    }
    return self;
}

- (void)didStartTask
{
    
}

- (void)didStopTask
{
    
}

@end
