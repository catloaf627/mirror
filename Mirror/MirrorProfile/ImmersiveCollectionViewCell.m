//
//  ImmersiveCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/10/24.
//

#import "ImmersiveCollectionViewCell.h"
#import "MirrorMacro.h"

static MirrorColorType const immersiveColorType = MirrorColorTypeCellYellow;
static NSString *const kPreferredImmersive = @"MirrorUserPreferredImmersiveMode";

@implementation ImmersiveCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCell
{
    [super configCellWithTitle:@"apply_immersive_mode" color:immersiveColorType];
    [self.toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kPreferredImmersive]) {
        [self.toggle setOn:YES animated:YES];
    } else {
        [self.toggle setOn:NO animated:YES];
    }
}

- (void)switchChanged:(UISwitch *)sender {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kPreferredImmersive]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPreferredImmersive];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kPreferredImmersive];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorSwitchImmersiveModeNotification object:nil];
}


@end
