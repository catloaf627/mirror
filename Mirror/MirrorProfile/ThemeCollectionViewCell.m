//
//  ThemeCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/28.
//

#import "ThemeCollectionViewCell.h"
#import "UIColor+MirrorColor.h"
#import "MirrorLanguage.h"
#import "MirrorMacro.h"

static MirrorColorType const themeColorType = MirrorColorTypeCellPink;
static NSString *const kPreferredDark = @"MirrorUserPreferredDarkMode";

@implementation ThemeCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCell
{
    [super configCellWithTitle:@"apply_darkmode" color:themeColorType];
    [self.toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kPreferredDark]) {
        [self.toggle setOn:YES animated:YES];
    } else {
        [self.toggle setOn:NO animated:YES];
    }
}

- (void)switchChanged:(UISwitch *)sender {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kPreferredDark]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPreferredDark];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kPreferredDark];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorSwitchThemeNotification object:nil];
}
    

@end
