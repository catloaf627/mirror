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
#import "PNChart.h"

@interface DataEntranceCollectionViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) PNPieChart *pieChart;

@end

@implementation DataEntranceCollectionViewCell

+ (NSString *)identifier;
{
    return NSStringFromClass(self.class);
}

- (void)configCellWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            self.titleLabel.text = [MirrorLanguage mirror_stringWithKey:@"today"];
            break;
        case 1:
            self.titleLabel.text = [MirrorLanguage mirror_stringWithKey:@"this_month"];
            break;
        case 2:
            self.titleLabel.text = [MirrorLanguage mirror_stringWithKey:@"this_year"];
            break;
        case 3:
            self.titleLabel.text = [MirrorLanguage mirror_stringWithKey:@"all_data"];
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

- (PNPieChart *)pieChart
{
    if (!_pieChart) {
        NSArray *items = @[[PNPieChartDataItem dataItemWithValue:10 color:[UIColor mirrorColorNamed:MirrorColorTypeCellOrange] description:@"english"],
                            [PNPieChartDataItem dataItemWithValue:20 color:[UIColor mirrorColorNamed:MirrorColorTypeCellPink] description:@"coding"],
                            [PNPieChartDataItem dataItemWithValue:40 color:[UIColor mirrorColorNamed:MirrorColorTypeCellBlue] description:@"reading"],];



        _pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(40.0, 155.0, 240.0, 240.0) items:items];
        _pieChart.descriptionTextColor = [UIColor clearColor]; // 小图不显示文案
//        _pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
        [_pieChart strokeChart];
        _pieChart.userInteractionEnabled = NO; // 小图禁止点击
        
    }
    return _pieChart;
}

@end
