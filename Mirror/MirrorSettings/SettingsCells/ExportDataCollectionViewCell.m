//
//  ExportDataCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/29.
//

#import "ExportDataCollectionViewCell.h"

static MirrorColorType const exportcellColorType = MirrorColorTypeCellTeal;

@implementation ExportDataCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCell
{
    [super configCellWithTitle:@"show_record_index" color:exportcellColorType];
    self.toggle.hidden = YES;
}

- (void)switchChanged:(UISwitch *)sender {
    
}

@end
