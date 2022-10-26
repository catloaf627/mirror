//
//  TimeTrackerTaskModel.m
//  Mirror
//
//  Created by wangyuqing on 2022/9/26.
//

#import "TimeTrackerTaskModel.h"
#import "MirrorLanguage.h"

@implementation TimeTrackerTaskModel

- (instancetype)initWithTitle:(NSString *)taskName colorType:(MirrorColorType)colorType isArchived:(BOOL)isArchived isOngoing:(BOOL)isOngoing isAddTask:(BOOL)isAddTaskModel
{
    self = [super init];
    if (self) {
        _taskName = taskName;
        _color = colorType;
        _isArchived = isArchived;
        _isOngoing = isOngoing;
        _timeInfo = [MirrorLanguage mirror_stringWithKey:@"tap_to_start"];
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
