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

@interface TaskTotalHeader ()

@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation TaskTotalHeader

- (void)configWithTaskname:(NSString *)taskname
{
    NSInteger count = 0;
    MirrorDataModel *task = [MirrorStorage getTaskFromDB:taskname];
    for (int i=0; i<task.periods.count; i++) {
        BOOL periodsIsFinished = task.periods[i].count == 2;
        if (periodsIsFinished) {
            long start = [task.periods[i][0] longValue];
            long end = [task.periods[i][1] longValue];
            count = count + (end-start);
        }
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
