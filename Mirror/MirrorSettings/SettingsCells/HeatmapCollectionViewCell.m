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
    NSArray *allColorType = @[@(MirrorColorTypeCellPinkPulse), @(MirrorColorTypeCellOrangePulse), @(MirrorColorTypeCellYellowPulse), @(MirrorColorTypeCellGreenPulse), @(MirrorColorTypeCellTealPulse), @(MirrorColorTypeCellBluePulse), @(MirrorColorTypeCellPurplePulse),@(MirrorColorTypeCellGrayPulse)];
    NSInteger randomColorType = [allColorType[arc4random() % allColorType.count] integerValue]; // 随机生成一个颜色（都是pulse色！不然叠上透明度就看不清了）
    [MirrorSettings changePreferredHeatmapColor:randomColorType];
}

@end
