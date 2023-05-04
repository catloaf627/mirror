//
//  MirrorDataModel.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/4.
//

#import "MirrorRecordModel.h"

@implementation MirrorRecordModel

- (instancetype)initWithTitle:(NSString *)taskName startTime:(long)startTime endTime:(long)endTime
{
    self = [super init];
    if (self) {
        _taskName = taskName;
        _startTime = startTime;
        _endTime = endTime;
    }
    return self;
}

#pragma mark - Encode Decode

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.taskName forKey:@"task_name"];
    [encoder encodeInt64:self.startTime forKey:@"start_time"];
    [encoder encodeInt64:self.endTime forKey:@"end_time"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.taskName = [decoder decodeObjectForKey:@"task_name"];
        self.startTime = [decoder decodeInt64ForKey:@"start_time"];
        self.endTime = [decoder decodeInt64ForKey:@"end_time"];
    }
    return self;
}


@end
