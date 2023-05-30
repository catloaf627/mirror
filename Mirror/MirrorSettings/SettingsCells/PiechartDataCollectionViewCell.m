//
//  PiechartDataCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/30.
//

#import "PiechartDataCollectionViewCell.h"
#import "MirrorSettings.h"

static MirrorColorType const piechartColorType = MirrorColorTypeCellGreen;

@implementation PiechartDataCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCell
{
    [super configCellWithTitle:@"show_histogram_on_data" color:piechartColorType];
    self.toggle.hidden = NO;
    [self.toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    if ([MirrorSettings appliedHistogramData]) {
        [self.toggle setOn:YES animated:YES];
    } else {
        [self.toggle setOn:NO animated:YES];
    }
}

- (void)switchChanged:(UISwitch *)sender {
    [MirrorSettings switchChartTypeData];
}

@end
