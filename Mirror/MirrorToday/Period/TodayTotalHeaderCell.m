//
//  TodayTotalHeaderCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/21.
//

#import "TodayTotalHeaderCell.h"
#import "MirrorDataModel.h"
#import "MirrorStorage.h"
#import <Masonry/Masonry.h>
#import "MirrorLanguage.h"

@interface TodayTotalHeaderCell ()

@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation TodayTotalHeaderCell

- (void)configWithTasknames:(NSArray<NSString *> *)taskNames periodIndexes:(NSArray *)indexes
{
    NSInteger count = 0;
    for (int i=0; i<taskNames.count; i++) {
        NSString *taskName = taskNames[i];
        NSInteger index = [indexes[i] integerValue];
        MirrorDataModel *task = [MirrorStorage getTaskFromDB:taskName];
        BOOL periodsIsFinished = task.periods[index].count == 2;
        if (periodsIsFinished) {
            long start = [task.periods[index][0] longValue];
            long end = [task.periods[index][1] longValue];
            count = count + (end-start);
        }
    }
    if (count >= 8*3600) { // 大于8小时，展示王冠
        [self.crownDelegate showCrown];
    } else { // 不到8小时，隐藏王冠
        [self.crownDelegate hideCrown];
    }
    [self addSubview:self.countLabel];
    self.countLabel.text = [[MirrorLanguage mirror_stringWithKey:@"total"] stringByAppendingString:[[NSDateComponentsFormatter new] stringFromTimeInterval:count]];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.right.offset(-20);
        make.bottom.offset(-10); // 和下面的cell的距离 与 cell之间的距离保持一致
        make.height.mas_equalTo(20);
    }];
}


- (UILabel *)countLabel
{
    if (!_countLabel) {
        _countLabel = [UILabel new];
        _countLabel.adjustsFontSizeToFitWidth = YES;
        _countLabel.textAlignment = NSTextAlignmentLeft;
        _countLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        _countLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:17];
    }
    return _countLabel;
}


@end
