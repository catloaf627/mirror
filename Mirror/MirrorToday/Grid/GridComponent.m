//
//  GridComponent.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/2.
//

#import "GridComponent.h"

@implementation GridComponent

- (instancetype)initWithValid:(BOOL)isValid thatDayData:(NSMutableArray<MirrorRecordModel *> *)thatDayData
{
    self = [super init];
    if (self) {
        _isValid = isValid;
        _thatDayData = thatDayData;
    }
    return self;
}

@end
