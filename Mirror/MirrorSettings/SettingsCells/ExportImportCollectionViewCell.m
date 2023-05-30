//
//  ExportImportCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/30.
//

#import "ExportImportCollectionViewCell.h"

static MirrorColorType const colorType = MirrorColorTypeCellPurple;

@implementation ExportImportCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCell
{
    [super configCellWithTitle:@"export_import_data" color:colorType];
    self.toggle.hidden = YES;
}

- (void)switchChanged:(UISwitch *)sender {
    
}

@end
