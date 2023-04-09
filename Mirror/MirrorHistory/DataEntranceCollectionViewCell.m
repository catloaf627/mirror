//
//  DataEntranceCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/4.
//

#import "DataEntranceCollectionViewCell.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "MirrorLanguage.h"
#import "MirrorDataManager.h"
#import "MirrorPiechart.h"
#import "MirrorStorage.h"


@interface DataEntranceCollectionViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) DataEntranceType type;
@property (nonatomic, strong) MirrorPiechart *pieChart;

@end

@implementation DataEntranceCollectionViewCell

+ (NSString *)identifier;
{
    return NSStringFromClass(self.class);
}

- (void)configCellWithType:(DataEntranceType)type
{
    _type = type;
    switch (type) {
        case DataEntranceTypeToday:
            self.titleLabel.text = [MirrorLanguage mirror_stringWithKey:@"today"];
            break;
        case DataEntranceTypeThisWeek:
            self.titleLabel.text = [MirrorLanguage mirror_stringWithKey:@"this_week"];
            break;
        case DataEntranceTypeThisMonth:
            self.titleLabel.text = [MirrorLanguage mirror_stringWithKey:@"this_month"];
            break;
        case DataEntranceTypeThisYear:
            self.titleLabel.text = [MirrorLanguage mirror_stringWithKey:@"this_year"];
            break;
        default:
            break;
    }
    [self p_setupUI];
}

- (void)p_setupUI
{
    self.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeAddTaskCellBG];
    self.layer.cornerRadius = 14;
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.offset(0);
        make.left.lessThanOrEqualTo(self).offset(20);
        make.right.lessThanOrEqualTo(self).offset(-20);
        make.height.mas_equalTo(self);
    }];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.offset(0);
    }];
    [self.contentView addSubview:self.pieChart];
    [self.pieChart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.right.offset(0);
        make.width.height.mas_equalTo(self.frame.size.height - 28);
    }];
}

#pragma mark - Getters

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:12];
        _titleLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeCellGrayPulse]; // 和nickname的文字颜色保持一致
    }
    return _titleLabel;
}

- (MirrorPiechart *)pieChart{
    if (!_pieChart) {
        if (_type == DataEntranceTypeToday) {
            _pieChart = [[MirrorPiechart alloc] initWithWidth:self.frame.size.height - 28 startedTime:[MirrorStorage startedTimeToday]];
        }
        if (_type == DataEntranceTypeThisWeek) {
            _pieChart = [[MirrorPiechart alloc] initWithWidth:self.frame.size.height - 28 startedTime:[MirrorStorage startedTimeThisWeek]];
        }
        if (_type == DataEntranceTypeThisMonth) {
            _pieChart = [[MirrorPiechart alloc] initWithWidth:self.frame.size.height - 28 startedTime:[MirrorStorage startedTimeThisMonth]];
        }
        if (_type == DataEntranceTypeThisYear) {
            _pieChart = [[MirrorPiechart alloc] initWithWidth:self.frame.size.height - 28 startedTime:[MirrorStorage startedTimeThisYear]];
        }
    }
    return _pieChart;
}

@end
