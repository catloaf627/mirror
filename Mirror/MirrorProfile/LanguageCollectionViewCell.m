//
//  LanguageCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/28.
//

#import "LanguageCollectionViewCell.h"
#import "UIColor+MirrorColor.h"

#import "MirrorLanguage.h"

static MirrorColorType const languageColorType = MirrorColorTypeCellOrange;
static NSString *const kPreferredChinese = @"MirrorUserPreferredChinese";

@implementation LanguageCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCell
{
    [super configCellWithTitle:@"apply_chinese" color:languageColorType];
    [self.toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kPreferredChinese]) {
        [self.toggle setOn:YES animated:YES];
    } else {
        [self.toggle setOn:NO animated:YES];
    }
}


- (void)switchChanged:(UISwitch *)sender {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kPreferredChinese]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPreferredChinese];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kPreferredChinese];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MirrorSwitchLanguageNotification" object:nil];
}

@end
