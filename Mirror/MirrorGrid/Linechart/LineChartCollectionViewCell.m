//
//  LineChartCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2024/3/6.
//

#import "LineChartCollectionViewCell.h"
#import "MirrorStorage.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>

static CGFloat const kPointSize = 10;

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
    NSLog(@"onedaydata count %lu", (unsigned long)onedaydata.count);
    self.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    _isLeft = leftdaydata == nil;
    _isRight = rightdaydata == nil;
    // remove all subviews
    NSArray *viewsToRemove = [self subviews];
    for (UIView *v in viewsToRemove) [v removeFromSuperview];
    // add new subviews
    for (id key in onedaydata.allKeys) {
        CGFloat percentage = [onedaydata[key] longValue] / (double)maxtime;
        UIView *point = [UIView new];
        point.backgroundColor = [UIColor mirrorColorNamed:[MirrorStorage getTaskModelFromDB:key].color];
        point.layer.cornerRadius = kPointSize/2;
        [self addSubview:point];
        [point mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(kPointSize);
            make.centerX.offset(0);
            make.centerY.mas_equalTo(-self.frame.size.height * percentage + self.frame.size.height/2);
        }];
    }
}

@end
