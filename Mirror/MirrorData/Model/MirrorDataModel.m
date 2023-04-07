//
//  MirrorDataModel.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import "MirrorDataModel.h"
#import "MirrorLanguage.h"

@implementation MirrorDataModel

- (instancetype)initWithTitle:(NSString *)taskName createdTime:(long)createTime colorType:(MirrorColorType)colorType isArchived:(BOOL)isArchived periods:(NSMutableArray<NSMutableArray *> *)periods isAddTask:(BOOL)isAddTaskModel
{
    self = [super init];
    if (self) {
        _taskName = taskName;
        _createdTime = createTime;
        _color = colorType;
        _isArchived = isArchived;
        _periods = periods;
        _isAddTaskModel = isAddTaskModel;
    }
    return self;
}

#pragma mark - Getters

- (BOOL)isOngoing // isOngoing并不由外界赋值，仅通过periods获得
{
    if (_periods.count > 0 && _periods[_periods.count-1].count == 1) {
        return YES;
    }
    return NO;
}

#pragma mark - Encode Decode

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.taskName forKey:@"task_name"];
    [encoder encodeBool:self.isArchived forKey:@"is_archived"];
    [encoder encodeInt:self.color forKey:@"color"];
    [encoder encodeObject:self.periods forKey:@"periods"];
    [encoder encodeInt64:self.createdTime forKey:@"created_time"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.taskName = [decoder decodeObjectForKey:@"task_name"];
        self.isArchived = [decoder decodeBoolForKey:@"is_archived"];
        self.color = [decoder decodeIntForKey:@"color"];
        self.periods = [decoder decodeObjectForKey:@"periods"];
        self.createdTime = [decoder decodeInt64ForKey:@"created_time"];
    }
    return self;
}
@end
