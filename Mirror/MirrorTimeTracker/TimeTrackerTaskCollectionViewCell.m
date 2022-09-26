//
//  TimeTrackerTaskCollectionViewCell.m
//  Mirror
//
//  Created by wangyuqing on 2022/9/26.
//

#import "TimeTrackerTaskCollectionViewCell.h"
#import <Masonry/Masonry.h>

@interface TimeTrackerTaskCollectionViewCell ()

@property (nonatomic, strong) UILabel *taskNameLabel;
@property (nonatomic, strong) UILabel *timeInfoLabel;

@end

@implementation TimeTrackerTaskCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_setupUI];
    }
    return self;
}

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)p_setupUI
{
    self.contentView.backgroundColor = [UIColor colorWithRed:245/255.0 green:218/255.0 blue:223/255.0 alpha:1];
    [self.contentView addSubview:self.taskNameLabel];
    [self.contentView addSubview:self.timeInfoLabel];
}

#pragma mark - Getters

- (UILabel *)taskNameLabel
{
    if (!_taskNameLabel) {
        _taskNameLabel = [[UILabel alloc] init];

    }
    return _taskNameLabel;
}

- (UILabel *)timeInfoLabel
{
    if (!_timeInfoLabel) {
        _timeInfoLabel = [[UILabel alloc] init];

    }
    return _timeInfoLabel;
}

@end
