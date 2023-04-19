//
//  MirrorSettings.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/10.
//

#import "MirrorSettings.h"
#import "MirrorMacro.h"

@implementation MirrorSettings

+ (BOOL)appliedDarkMode
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredDarkMode"];
}

+ (void)switchTheme
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredDarkMode"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MirrorUserPreferredDarkMode"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MirrorUserPreferredDarkMode"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorSwitchThemeNotification object:nil];
}

+ (BOOL)appliedChinese
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredChinese"];
}

+ (void)switchLanguage
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredChinese"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MirrorUserPreferredChinese"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MirrorUserPreferredChinese"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorSwitchLanguageNotification object:nil];
}

+ (BOOL)appliedImmersiveMode
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredImmersiveMode"];
}

+ (void)switchTimerMode
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredImmersiveMode"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MirrorUserPreferredImmersiveMode"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MirrorUserPreferredImmersiveMode"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorSwitchTimerModeNotification object:nil];
}

+ (BOOL)appliedWeekStarsOnMonday
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredWeekStartsOnMonday"];
}

+ (void)switchWeekStartsOn
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredWeekStartsOnMonday"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MirrorUserPreferredWeekStartsOnMonday"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MirrorUserPreferredWeekStartsOnMonday"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MirrorSwitchWeekStartsOnNotification object:nil];
}


@end
