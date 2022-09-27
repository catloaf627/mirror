//
//  TimeTrackerTaskModel.m
//  Mirror
//
//  Created by wangyuqing on 2022/9/26.
//

#import "TimeTrackerTaskModel.h"
#import "MirrorLanguage.h"

@implementation TimeTrackerTaskModel

- (instancetype)initWithTitle:(NSString *)taskName color:(UIColor *)color
{
    self = [super init];
    if (self) {
        _taskName = taskName;
        _color = color;
        _timeInfo = [MirrorLanguage stringWithKey:@"tap_to_start" Language:MirrorLanguageTypeEnglish];
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
