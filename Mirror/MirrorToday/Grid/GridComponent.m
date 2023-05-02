//
//  GridComponent.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/2.
//

#import "GridComponent.h"

@implementation GridComponent

- (instancetype)initWithValid:(BOOL)isValid thatDayTasks:(NSMutableArray<MirrorDataModel *> *)thatDayTasks
{
    self = [super init];
    if (self) {
        _isValid = isValid;
        _thatDayTasks = thatDayTasks;
    }
    return self;
}

@end
