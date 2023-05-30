//
//  ReportBugCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/30.
//

#import "ReportBugCollectionViewCell.h"

static MirrorColorType const colorType = MirrorColorTypeCellGray;

@implementation ReportBugCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCell
{
    [super configCellWithTitle:@"contact_me" color:colorType];
    self.toggle.hidden = YES;
}

- (void)switchChanged:(UISwitch *)sender {
    
}

@end
