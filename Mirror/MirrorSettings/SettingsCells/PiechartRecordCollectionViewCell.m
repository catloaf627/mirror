//
//  PiechartRecordCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/30.
//

#import "PiechartRecordCollectionViewCell.h"
#import "MirrorSettings.h"

static MirrorColorType const piechartColorType = MirrorColorTypeCellTeal;

@implementation PiechartRecordCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCell
{
    [super configCellWithTitle:@"show_piechart_on_record" color:piechartColorType];
    self.toggle.hidden = NO;
    [self.toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    if ([MirrorSettings appliedPieChartRecord]) {
        [self.toggle setOn:YES animated:YES];
    } else {
        [self.toggle setOn:NO animated:YES];
    }
}

- (void)switchChanged:(UISwitch *)sender {
    [MirrorSettings switchChartTypeRecord];
}

@end
