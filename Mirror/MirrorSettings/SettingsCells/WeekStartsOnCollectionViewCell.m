//
//  WeekStartsOnCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/11.
//

#import "WeekStartsOnCollectionViewCell.h"
#import "MirrorSettings.h"

@implementation WeekStartsOnCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCell
{
    [super configCellWithTitle:@"week_starts_on_Monday" color:MirrorColorTypeCellYellow];
    self.toggle.hidden = NO;
    [self.toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    if ([MirrorSettings appliedWeekStarsOnMonday]) {
        [self.toggle setOn:YES animated:YES];
    } else {
        [self.toggle setOn:NO animated:YES];
    }
}

- (void)switchChanged:(UISwitch *)sender {
    [MirrorSettings switchWeekStartsOn];
}

@end
