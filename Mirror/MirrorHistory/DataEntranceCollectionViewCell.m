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
#import "MirrorTool.h"
@interface DataEntranceCollectionViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray<MirrorDataModel *> *tasks;
@property (nonatomic, assign) DataEntranceType type;

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
            self.tasks = [MirrorDataManager todayTasks];
            break;
        case DataEntranceTypeThisWeek:
            self.titleLabel.text = [MirrorLanguage mirror_stringWithKey:@"this_week"];
            self.tasks = [MirrorDataManager weekTasks];
            break;
        case DataEntranceTypeThisMonth:
            self.titleLabel.text = [MirrorLanguage mirror_stringWithKey:@"this_month"];
            self.tasks = [MirrorDataManager monthTasks];
            break;
        case DataEntranceTypeThisYear:
            self.titleLabel.text = [MirrorLanguage mirror_stringWithKey:@"this_year"];
            self.tasks = [MirrorDataManager yearTasks];
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

@end
