//
//  TaskTotalHeader.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/23.
//

#import "TaskTotalHeader.h"
#import "MirrorDataModel.h"
#import "MirrorStorage.h"
#import <Masonry/Masonry.h>
#import "MirrorLanguage.h"
#import "MirrorTimeText.h"
#import "MirrorTool.h"

@interface TaskTotalHeader ()

@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation TaskTotalHeader

- (void)config
{
    NSMutableArray<MirrorDataModel *> *chartModels = [MirrorStorage getAllRecordsInTaskOrderWithStart:0 end:LONG_MAX];
    long count = 0;
    for (int i=0; i<chartModels.count; i++) {
        count = count + [MirrorTool getTotalTimeOfPeriods:chartModels[i].records];
    }
    [self addSubview:self.countLabel];
    self.countLabel.text = [[MirrorLanguage mirror_stringWithKey:@"total"] stringByAppendingString:[MirrorTimeText XdXhXmXsFull:count]];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.right.offset(-20);
        make.bottom.offset(-10); // 和下面的cell的距离 与 cell之间的距离保持一致
        make.height.mas_equalTo(20);
    }];
}

- (void)configWithTaskname:(NSString *)taskname
{
    NSMutableArray<MirrorDataModel *> *chartModels = [MirrorStorage getAllRecordsInTaskOrderWithStart:0 end:LONG_MAX];
    MirrorDataModel *chartModel = nil;
    for (int i=0; i<chartModels.count; i++) {
        if ([chartModels[i].taskModel.taskName isEqualToString:taskname]) {
            chartModel = chartModels[i];
            break;
        }
    }
    long count = [MirrorTool getTotalTimeOfPeriods:chartModel.records];
    [self addSubview:self.countLabel];
    self.countLabel.text = [[MirrorLanguage mirror_stringWithKey:@"total"] stringByAppendingString:[MirrorTimeText XdXhXmXsFull:count]];
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
