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
#import "TimeTrackingLabel.h"
#import "MirrorStorage.h"

static CGFloat const kShadowWidth = 5;

@interface TimeTrackerTaskCollectionViewCell () <TimeTrackingLabelProtocol>

@property (nonatomic, strong) MirrorDataModel *taskModel;
@property (nonatomic, strong) UILabel *taskNameLabel;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, assign) BOOL applyImmersiveMode;
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
    self.hintLabel.text = [MirrorLanguage mirror_stringWithKey:@"tap_to_start"];
    self.contentView.backgroundColor = [UIColor mirrorColorNamed:taskModel.color];
    self.applyImmersiveMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredImmersiveMode"];

    [self p_setupUI];
    if (!taskModel.isOngoing) { // stop animation
        self.contentView.backgroundColor = [UIColor mirrorColorNamed:self.taskModel.color]; // 瞬间变回原色
    } else { // start animation
        self.contentView.backgroundColor = [UIColor mirrorColorNamed:[UIColor mirror_getPulseColorType:self.taskModel.color]]; // 瞬间变成pulse色
        [self p_convertToColor:self.taskModel.color]; // 开始闪烁
        [self createTimeTrackingLabelWithTask:taskModel];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) { // cell被销毁
        for (UIView *view in self.contentView.subviews) {
            if ([view isKindOfClass:TimeTrackingLabel.class]) {
                [view removeFromSuperview];
            }
        }
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
    [self.contentView addSubview:self.hintLabel];
    [self.taskNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self).offset(-8);
        make.left.offset(8);
        make.right.offset(-8);
    }];
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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

#pragma mark - TimeTrackingLabelProtocol

- (void)destroyTimeTrackingLabelWithTask:(MirrorDataModel *)task
{
    for (UIView *view in self.contentView.subviews) {
        if ([view isKindOfClass:TimeTrackingLabel.class]) {
            [view removeFromSuperview];
        }
    }
    self.hintLabel.hidden = NO;
}

- (void)createTimeTrackingLabelWithTask:(MirrorDataModel *)task
{
    if (!task.isOngoing) return;
    if (self.applyImmersiveMode) return;
    TimeTrackingLabel *timeTrackingLabel = [[TimeTrackingLabel alloc] initWithTask:self.taskModel.taskName];
    timeTrackingLabel.delegate = self;
    // 避免复用导致的重复添加
    for (UIView *view in self.contentView.subviews) {
        if ([view isKindOfClass:TimeTrackingLabel.class]) {
            [view removeFromSuperview];
        }
    }
    // 和hintLabel布局一致
    [self.contentView addSubview:timeTrackingLabel];
    [timeTrackingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.taskNameLabel.mas_bottom).offset(8);
        make.centerX.mas_equalTo(self);
        make.left.offset(8);
        make.right.offset(-8);
    }];
    self.hintLabel.hidden = YES;
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

- (UILabel *)hintLabel
{
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.text = self.taskModel.isOngoing ? [MirrorLanguage mirror_stringWithKey:@"tap_to_stop"] : [MirrorLanguage mirror_stringWithKey:@"tap_to_start"];
        _hintLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        _hintLabel.numberOfLines = 1;
        _hintLabel.textAlignment = NSTextAlignmentCenter;
        _hintLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    }
    return _hintLabel;
}

@end
