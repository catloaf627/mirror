//
//  ImportDataCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/29.
//

#import "ImportDataCollectionViewCell.h"

static MirrorColorType const importcellColorType = MirrorColorTypeCellPurple;

@implementation ImportDataCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCell
{
    [super configCellWithTitle:@"import_data" color:importcellColorType];
    self.toggle.hidden = YES;
}

- (void)switchChanged:(UISwitch *)sender {
    
}


@end
