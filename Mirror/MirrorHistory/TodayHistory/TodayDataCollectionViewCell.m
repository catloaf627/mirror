//
//  TodayDataCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/4.
//

#import "TodayDataCollectionViewCell.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>

@interface TodayDataCollectionViewCell ()

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *taskNameLabel;

@end


@implementation TodayDataCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCellWithModel:(TimeTrackerTaskModel *)model
{
    self.backgroundColor = [UIColor mirrorColorNamed:model.color];
    self.layer.cornerRadius = 15;
    self.taskNameLabel.text = model.taskName;
    [self p_setupUI];
}

- (void)p_setupUI
{
    [self addSubview:self.icon];
    [self addSubview:self.taskNameLabel];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.right.offset(-20);
        make.height.width.mas_equalTo(20);
    }];
    [self.taskNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.offset(20);
    }];
    
}

#pragma mark - Getters

- (UIImageView *)icon
{
    if (!_icon) {
        _icon = [UIImageView new];
        UIImage *iconImage = [UIImage systemImageNamed:@"square.and.pencil"];
        _icon.image = [iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _icon.tintColor = [UIColor blackColor];
    }
    return _icon;
}

- (UILabel *)taskNameLabel
{
    if (!_taskNameLabel) {
        _taskNameLabel = [UILabel new];
        _taskNameLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        _taskNameLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:17];
    }
    return _taskNameLabel;
}


@end
