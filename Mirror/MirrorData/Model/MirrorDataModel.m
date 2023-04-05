//
//  MirrorDataModel.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import "MirrorDataModel.h"
#import "MirrorLanguage.h"

@implementation MirrorDataModel

- (instancetype)initWithTitle:(NSString *)taskName createdTime:(long)createTime colorType:(MirrorColorType)colorType isArchived:(BOOL)isArchived isOngoing:(BOOL)isOngoing isAddTask:(BOOL)isAddTaskModel
{
    self = [super init];
    if (self) {
        _taskName = taskName;
        _createdTime = createTime;
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
