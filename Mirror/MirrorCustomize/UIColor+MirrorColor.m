//
//  UIColor+MirrorColor.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/25.
//

#import "UIColor+MirrorColor.h"

@implementation UIColor (MirrorColor)

+ (UIColor *)mirrorColorNamed:(MirrorColorType)colorType
{
    BOOL isLight = ![[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredDarkMode"];
    switch (colorType) {
        case MirrorColorTypeBackground:
            return isLight ? [UIColor whiteColor] : [UIColor blackColor];
        case MirrorColorTypeTabbarIconText:
            return [UIColor grayColor];
        case MirrorColorTypeTabbarIconTextHightlight:
            return isLight ? [UIColor blackColor] : [UIColor whiteColor];
        case MirrorColorTypeText:
            return isLight ? [UIColor blackColor] : [UIColor whiteColor];
        case MirrorColorTypeTextHint: // 和cell gray pulse一样
            return isLight ? [UIColor mirror_darkGray] : [UIColor mirror_lightGray];
        case MirrorColorTypeShadow:
            return [UIColor grayColor];
        case MirrorColorTypeAddTaskCellBG:
            return isLight ? [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1] : [UIColor colorWithRed:15/255.0 green:15/255.0 blue:15/255.0 alpha:1];
        case MirrorColorTypeAddTaskCellPlus:
            return isLight ? [UIColor colorWithRed:200/255.0 green: 200/255.0  blue:200/255.0 alpha:1] : [UIColor colorWithRed:55/255.0 green: 55/255.0  blue:55/255.0 alpha:1];
        case MirrorColorTypeCellPink:
            return isLight ? [UIColor mirror_lightPink] : [UIColor mirror_darkPink];
        case MirrorColorTypeCellPinkPulse:
            return isLight ? [UIColor mirror_darkPink] : [UIColor mirror_lightPink];
        case MirrorColorTypeCellOrange:
            return isLight ? [UIColor mirror_lightOrange] : [UIColor mirror_darkOrange];
        case MirrorColorTypeCellOrangePulse:
            return isLight ? [UIColor mirror_darkOrange] : [UIColor mirror_lightOrange];
        case MirrorColorTypeCellYellow:
            return isLight ? [UIColor mirror_lightYellow] : [UIColor mirror_darkYellow];
        case MirrorColorTypeCellYellowPulse:
            return isLight ? [UIColor mirror_darkYellow] : [UIColor mirror_lightYellow];
        case MirrorColorTypeCellGreen:
            return isLight ? [UIColor mirror_lightGreen] : [UIColor mirror_darkGreen];
        case MirrorColorTypeCellGreenPulse:
            return isLight ? [UIColor mirror_darkGreen] : [UIColor mirror_lightGreen];
        case MirrorColorTypeCellTeal:
            return isLight ? [UIColor mirror_lightTeal] : [UIColor mirror_darkTeal];
        case MirrorColorTypeCellTealPulse:
            return isLight ? [UIColor mirror_darkTeal] : [UIColor mirror_lightTeal];
        case MirrorColorTypeCellBlue:
            return isLight ? [UIColor mirror_lightBlue] : [UIColor mirror_darkBlue];
        case MirrorColorTypeCellBluePulse:
            return isLight ? [UIColor mirror_darkBlue] : [UIColor mirror_lightBlue];
        case MirrorColorTypeCellPurple:
            return isLight ? [UIColor mirror_lightPurple] : [UIColor mirror_darkPurple];
        case MirrorColorTypeCellPurplePulse:
            return isLight ? [UIColor mirror_darkPurple] : [UIColor mirror_lightPurple];
        case MirrorColorTypeCellGray:
            return isLight ? [UIColor mirror_lightGray] : [UIColor mirror_darkGray];
        case MirrorColorTypeCellGrayPulse:
            return isLight ? [UIColor mirror_darkGray] : [UIColor mirror_lightGray];
        default:
            return [UIColor clearColor];
    }
}

+ (MirrorColorType)mirror_getPulseColorType:(MirrorColorType)color
{
    switch (color) {
        case MirrorColorTypeCellPink:
            return MirrorColorTypeCellPinkPulse;
        case MirrorColorTypeCellOrange:
            return MirrorColorTypeCellOrangePulse;
        case MirrorColorTypeCellYellow:
            return MirrorColorTypeCellYellowPulse;
        case MirrorColorTypeCellGreen:
            return MirrorColorTypeCellGreenPulse;
        case MirrorColorTypeCellTeal:
            return MirrorColorTypeCellTealPulse;
        case MirrorColorTypeCellBlue:
            return MirrorColorTypeCellBluePulse;
        case MirrorColorTypeCellPurple:
            return MirrorColorTypeCellPurplePulse;
        case MirrorColorTypeCellGray:
            return MirrorColorTypeCellGrayPulse;
        default:
            return MirrorColorTypeBackground;
    }
}

+ (UIColor *)mirror_lightPink
{
    return [UIColor colorWithRed:224/255.0 green:205/255.0 blue:207/255.0 alpha:1]; // 莫兰迪粉
}

+ (UIColor *)mirror_darkPink
{
    return [UIColor colorWithRed:177/255.0 green:122/255.0 blue:125/255.0 alpha:1]; // 莫兰迪深粉
}

+ (UIColor *)mirror_lightOrange
{
    return [UIColor colorWithRed:248/255.0 green:235/255.0 blue:216/255.0 alpha:1]; // 莫兰迪橘
}

+ (UIColor *)mirror_darkOrange
{
    return [UIColor colorWithRed:160/255.0 green:106/255.0 blue:80/255.0 alpha:1]; // 莫兰迪深橘
}

+ (UIColor *)mirror_lightYellow
{
    return [UIColor colorWithRed:253/255.0 green:249/255.0 blue:238/255.0 alpha:1]; // 莫兰迪黄
}

+ (UIColor *)mirror_darkYellow
{
    return [UIColor colorWithRed:166/255.0 green:142/255.0 blue:118/255.0 alpha:1]; // 莫兰迪深黄（棕）
}

+ (UIColor *)mirror_lightGreen
{
    return [UIColor colorWithRed:224/255.0 green:229/255.0 blue:223/255.0 alpha:1]; // 莫兰迪绿
}

+ (UIColor *)mirror_darkGreen
{
    return [UIColor colorWithRed:122/255.0 green:103/255.0 blue:71/255.0 alpha:1]; // 莫兰迪深绿
}

+ (UIColor *)mirror_lightTeal
{
    return [UIColor colorWithRed:212/255.0 green:231/255.0 blue:234/255.0 alpha:1]; // 莫兰迪青
}

+ (UIColor *)mirror_darkTeal
{
    return [UIColor colorWithRed:69/255.0 green:137/255.0 blue:148/255.0 alpha:1]; // 莫兰迪深青
}

+ (UIColor *)mirror_lightBlue
{
    return [UIColor colorWithRed:193/255.0 green:203/255.0 blue:215/255.0 alpha:1]; // 莫兰迪蓝
}

+ (UIColor *)mirror_darkBlue
{
    return [UIColor colorWithRed:104/255.0 green:120/255.0 blue:137/255.0 alpha:1]; // 莫兰迪深蓝
}

+ (UIColor *)mirror_lightPurple
{
    return [UIColor colorWithRed:216/255.0 green:207/255.0 blue:226/255.0 alpha:1]; // 莫兰迪紫
}

+ (UIColor *)mirror_darkPurple
{
    return [UIColor colorWithRed:105/255.0 green:100/255.0 blue:123/255.0 alpha:1]; // 莫兰迪深紫
}

+ (UIColor *)mirror_lightGray
{
    return [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1]; // 莫兰迪灰
}

+ (UIColor *)mirror_darkGray
{
    return [UIColor colorWithRed:147/255.0 green:147/255.0 blue:145/255.0 alpha:1]; // 莫兰迪深灰
}

@end
