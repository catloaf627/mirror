//
//  ImmersiveCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/10/24.
//

#import "ImmersiveCollectionViewCell.h"
#import "MirrorSettings.h"

static MirrorColorType const immersiveColorType = MirrorColorTypeCellYellow;

@implementation ImmersiveCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCell
{
    [super configCellWithTitle:@"apply_immersive_mode" color:immersiveColorType];
    [self.toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    if ([MirrorSettings appliedImmersiveMode]) {
        [self.toggle setOn:YES animated:YES];
    } else {
        [self.toggle setOn:NO animated:YES];
    }
}

- (void)switchChanged:(UISwitch *)sender {
    [MirrorSettings switchTimerMode];
}


@end
