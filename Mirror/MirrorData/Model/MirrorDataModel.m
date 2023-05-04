//
//  MirrorDataModel.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/4.
//

#import "MirrorDataModel.h"

@implementation MirrorDataModel

- (instancetype)initWithTask:(MirrorTaskModel *)taskModel records:(NSMutableArray<MirrorRecordModel *> *)records
{
    self = [super init];
    if (self) {
        _taskModel = taskModel;
        _records = records;
    }
    return self;
}


@end
