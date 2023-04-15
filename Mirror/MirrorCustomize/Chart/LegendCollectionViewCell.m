//
//  LegendCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/15.
//

#import "LegendCollectionViewCell.h"
#import <Masonry/Masonry.h>

static CGFloat const kPadding = 10;

@interface LegendCollectionViewCell ()

@property (nonatomic, strong) UIView *coloredView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation LegendCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCellWithTask:(MirrorDataModel *)task
{
    [self addSubview:self.coloredView];
    self.coloredView.backgroundColor = [UIColor mirrorColorNamed:task.color];
    self.coloredView.layer.borderColor = [UIColor mirrorColorNamed: [UIColor mirror_getPulseColorType:task.color]].CGColor;
    self.coloredView.layer.borderWidth = 2;
    [self.coloredView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@20);
        make.centerY.offset(0);
        make.left.offset(kPadding);
    }];
    
    [self addSubview:self.label];
    self.label.textColor = [UIColor mirrorColorNamed: [UIColor mirror_getPulseColorType:task.color]];
    self.label.text = task.taskName;
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@20);
        make.centerY.offset(0);
        make.left.mas_equalTo(self.coloredView.mas_right).offset(kPadding);
        make.right.offset(-kPadding);
    }];
}

- (UIView *)coloredView
{
    if (!_coloredView) {
        _coloredView = [UIView new];
    }
    return _coloredView;
}

- (UILabel *)label
{
    if (!_label) {
        _label = [UILabel new];
    }
    return _label;
}

@end
