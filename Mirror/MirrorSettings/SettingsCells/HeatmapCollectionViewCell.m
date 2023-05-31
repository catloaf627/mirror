//
//  HeatmapCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/30.
//

#import "HeatmapCollectionViewCell.h"
#import "MirrorSettings.h"

static MirrorColorType const gridcellColorType = MirrorColorTypeCellBlue;

@implementation HeatmapCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCell
{
    [super configCellWithTitle:@"heatmap" color:gridcellColorType];
    self.toggle.hidden = NO;
    [self.toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    if ([MirrorSettings appliedHeatmap]) {
        [self.toggle setOn:YES animated:YES];
    } else {
        [self.toggle setOn:NO animated:YES];
    }
}

- (void)switchChanged:(UISwitch *)sender {
    [MirrorSettings switchHeatmap];
}

@end
