//
//  TimeTrackerAddTaskCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/28.
//

#import "TimeTrackerAddTaskCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+MirrorColor.h"

static CGFloat const kShadowWidth = 5;

@interface TimeTrackerAddTaskCollectionViewCell ()

@property (nonatomic, strong) UIView *horizontalLine;
@property (nonatomic, strong) UIView *verticalLine;

@end

@implementation TimeTrackerAddTaskCollectionViewCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self p_setupUI];
    }
    return self;
}

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)setupAddTaskCell
{
    [self p_setupUI];
}

- (void)p_setupUI
{
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kShadowWidth);
        make.right.offset(-kShadowWidth);
        make.top.offset(kShadowWidth);
        make.bottom.offset(-kShadowWidth);
    }];
    self.contentView.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    self.contentView.layer.cornerRadius = 14;
    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.shadowRadius = kShadowWidth/2;
    self.contentView.layer.shadowOpacity = 1;
    
    [self.contentView addSubview:self.horizontalLine];
    [self.contentView addSubview:self.verticalLine];
    
    [self.verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.offset(0);
        make.height.mas_equalTo(self.contentView).multipliedBy(0.6);
        make.width.mas_equalTo(7);
    }];
    
    [self.horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.offset(0);
        make.height.mas_equalTo(7);
        make.width.mas_equalTo(_verticalLine.mas_height);
    }];
}

#pragma mark - Getters

- (UIView *)horizontalLine
{
    if (!_horizontalLine) {
        _horizontalLine = [UIView new];
        _horizontalLine.backgroundColor = [UIColor colorWithRed:199/255.0 green: 198/255.0  blue:193/255.0 alpha:1];
        _horizontalLine.layer.cornerRadius = 3;
    }
    return _horizontalLine;
}

- (UIView *)verticalLine
{
    if (!_verticalLine) {
        _verticalLine = [UIView new];
        _verticalLine.backgroundColor = [UIColor colorWithRed:199/255.0 green: 198/255.0  blue:193/255.0 alpha:1];
        _verticalLine.layer.cornerRadius = 3;
    }
    return _verticalLine;
}


@end
