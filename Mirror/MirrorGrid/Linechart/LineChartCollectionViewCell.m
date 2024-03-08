//
//  LineChartCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2024/3/6.
//

#import "LineChartCollectionViewCell.h"

@interface LineChartCollectionViewCell ()

@property (nonatomic, assign) BOOL isLeft; // 是最左边的cell
@property (nonatomic, assign) BOOL isRight; // 是最右边的cell

@end

@implementation LineChartCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCellWithOnedaydata:(NSMutableDictionary<NSString *, NSNumber *> *)onedaydata
                     leftdaydata:(NSMutableDictionary<NSString *, NSNumber *> *)leftdaydata
                    rightdaydata:(NSMutableDictionary<NSString *, NSNumber *> *)rightdaydata
                         maxtime:(long)maxtime
{
    _isLeft = leftdaydata == nil;
    _isRight = rightdaydata == nil;
    for (id key in onedaydata.allKeys) {
        NSLog(@"这天 %ld", [onedaydata[key] longValue]);
        if (!_isLeft) NSLog(@"前一天 %ld", [leftdaydata[key] longValue]);
        if (!_isRight) NSLog(@"前一天 %ld", [rightdaydata[key] longValue]);
    }
    self.backgroundColor = [UIColor yellowColor];
}

@end
