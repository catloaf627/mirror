//
//  LanguageCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/28.
//

#import "LanguageCollectionViewCell.h"
#import "UIColor+MirrorColor.h"
#import "MirrorSettings.h"
#import "MirrorLanguage.h"

static MirrorColorType const languageColorType = MirrorColorTypeCellPink;

@implementation LanguageCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCell
{
    [super configCellWithTitle:@"apply_chinese" color:languageColorType];
    self.toggle.hidden = NO;
    [self.toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    if ([MirrorSettings appliedChinese]) {
        [self.toggle setOn:YES animated:YES];
    } else {
        [self.toggle setOn:NO animated:YES];
    }
}


- (void)switchChanged:(UISwitch *)sender {
    [MirrorSettings switchLanguage];
}

@end
