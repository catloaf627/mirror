//
//  ShowIndexCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/5.
//

#import "ShowIndexCollectionViewCell.h"
#import "MirrorSettings.h"

@implementation ShowIndexCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCell
{
    [super configCellWithTitle:@"show_record_indexes" color:MirrorColorTypeCellOrange];
    self.toggle.hidden = NO;
    [self.toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    if ([MirrorSettings appliedShowIndex]) {
        [self.toggle setOn:YES animated:YES];
    } else {
        [self.toggle setOn:NO animated:YES];
    }
}

- (void)switchChanged:(UISwitch *)sender {
    [MirrorSettings switchShowIndex];
}


@end
