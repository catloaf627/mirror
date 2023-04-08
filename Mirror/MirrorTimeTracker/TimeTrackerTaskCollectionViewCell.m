//
//  TimeTrackerTaskCollectionViewCell.m
//  Mirror
//
//  Created by wangyuqing on 2022/9/26.
//

#import "TimeTrackerTaskCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+MirrorColor.h"
#import "MirrorLanguage.h"

static CGFloat const kShadowWidth = 5;

@interface TimeTrackerTaskCollectionViewCell ()

@property (nonatomic, strong) MirrorDataModel *taskModel;
@property (nonatomic, strong) UILabel *taskNameLabel;
@property (nonatomic, strong) UILabel *timeInfoLabel;

@end

@implementation TimeTrackerTaskCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configWithModel:(MirrorDataModel *)taskModel
{
    self.taskModel = taskModel;
    self.taskNameLabel.text = taskModel.taskName;
    self.timeInfoLabel.text = taskModel.isOngoing ? [MirrorLanguage mirror_stringWithKey:@"tap_to_stop"] : [MirrorLanguage mirror_stringWithKey:@"tap_to_start"];
    self.contentView.backgroundColor = [UIColor mirrorColorNamed:taskModel.color];
    [self p_setupUI];
    if (!taskModel.isOngoing) { // stop animation
        self.contentView.backgroundColor = [UIColor mirrorColorNamed:self.taskModel.color]; // 瞬间变回原色
    } else { // start animation
        self.contentView.backgroundColor = [UIColor mirrorColorNamed:[UIColor mirror_getPulseColorType:self.taskModel.color]]; // 瞬间变成pulse色
        [self p_convertToColor:self.taskModel.color]; // 开始闪烁
    }
}

- (void)p_setupUI
{
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kShadowWidth);
        make.right.offset(-kShadowWidth);
        make.top.offset(kShadowWidth);
        make.bottom.offset(-kShadowWidth);
    }];
    self.contentView.backgroundColor = [UIColor mirrorColorNamed:self.taskModel.color];
    self.contentView.layer.cornerRadius = 14;
    self.contentView.layer.shadowColor = [UIColor mirrorColorNamed:MirrorColorTypeShadow].CGColor;
    self.contentView.layer.shadowRadius = kShadowWidth/2;
    self.contentView.layer.shadowOpacity = 1;
    
    [self.contentView addSubview:self.taskNameLabel];
    [self.contentView addSubview:self.timeInfoLabel];
    [self.taskNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self).offset(-8);
        make.left.offset(8);
        make.right.offset(-8);
    }];
    [self.timeInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.taskNameLabel.mas_bottom).offset(8);
        make.centerX.mas_equalTo(self);
        make.left.offset(8);
        make.right.offset(-8);
    }];
}

- (void)p_convertToColor:(MirrorColorType)color
{
    [UIView animateKeyframesWithDuration:2.0  delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
        self.contentView.backgroundColor = [UIColor mirrorColorNamed:color];
    } completion:^(BOOL finished) {
        if (!finished) {
            return;
        }
        if (CGColorEqualToColor(self.contentView.backgroundColor.CGColor, [UIColor mirrorColorNamed:self.taskModel.color].CGColor)) {
            [self p_convertToColor:[UIColor mirror_getPulseColorType:self.taskModel.color]];
        } else {
            [self p_convertToColor:self.taskModel.color];
        }
    }];
}


#pragma mark - Getters

- (UILabel *)taskNameLabel
{
    if (!_taskNameLabel) {
        _taskNameLabel = [[UILabel alloc] init];
        _taskNameLabel.text = self.taskModel.taskName;
        _taskNameLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        _taskNameLabel.numberOfLines = 1;
        _taskNameLabel.textAlignment = NSTextAlignmentCenter;
        _taskNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22];
    }
    return _taskNameLabel;
}

- (UILabel *)timeInfoLabel
{
    if (!_timeInfoLabel) {
        _timeInfoLabel = [[UILabel alloc] init];
        _timeInfoLabel.text = self.taskModel.isOngoing ? [MirrorLanguage mirror_stringWithKey:@"tap_to_stop"] : [MirrorLanguage mirror_stringWithKey:@"tap_to_start"];
        _timeInfoLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        _timeInfoLabel.numberOfLines = 1;
        _timeInfoLabel.textAlignment = NSTextAlignmentCenter;
        _timeInfoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    }
    return _timeInfoLabel;
}

@end
