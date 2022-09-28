//
//  UIColor+MirrorColor.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/25.
//

#import "UIColor+MirrorColor.h"

@implementation UIColor (MirrorColor)

static MirrorUserInterfaceStyle _interfaceStyle = MirrorUserInterfaceStyleLight;

+ (void)switchTheme
{
    if (_interfaceStyle == MirrorUserInterfaceStyleLight) {
        _interfaceStyle = MirrorUserInterfaceStyleDark;
    } else {
        _interfaceStyle = MirrorUserInterfaceStyleLight;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MirrorSwitchThemeNotification" object:nil];
}

+ (UIColor *)mirrorColorNamed:(MirrorColorType)colorType
{
    switch (colorType) {
        case MirrorColorTypeBackground:
            return _interfaceStyle == MirrorUserInterfaceStyleLight ? [UIColor whiteColor] : [UIColor blackColor];
        case MirrorColorTypeTabbarIconText:
            return [UIColor grayColor];
        case MirrorColorTypeTabbarIconTextHightlight:
            return _interfaceStyle == MirrorUserInterfaceStyleLight ? [UIColor blackColor] : [UIColor whiteColor];
        case MirrorColorTypeText:
            return _interfaceStyle == MirrorUserInterfaceStyleLight ? [UIColor blackColor] : [UIColor whiteColor];
        case MirrorColorTypeShadow:
            return _interfaceStyle == MirrorUserInterfaceStyleLight ? [UIColor grayColor] : [UIColor lightGrayColor];
        case MirrorColorTypeCellPink:
            return _interfaceStyle == MirrorUserInterfaceStyleLight ? [UIColor mirror_lightPink] : [UIColor mirror_darkPink];
        case MirrorColorTypeCellPinkPulse:
            return _interfaceStyle == MirrorUserInterfaceStyleLight ? [UIColor mirror_darkPink] : [UIColor mirror_lightPink];
        case MirrorColorTypeCellOrange:
            return _interfaceStyle == MirrorUserInterfaceStyleLight ? [UIColor mirror_lightOrange] : [UIColor mirror_darkOrange];
        case MirrorColorTypeCellOrangePulse:
            return _interfaceStyle == MirrorUserInterfaceStyleLight ? [UIColor mirror_darkOrange] : [UIColor mirror_lightOrange];
        case MirrorColorTypeCellYellow:
            return _interfaceStyle == MirrorUserInterfaceStyleLight ? [UIColor mirror_lightYellow] : [UIColor mirror_darkYellow];
        case MirrorColorTypeCellYellowPulse:
            return _interfaceStyle == MirrorUserInterfaceStyleLight ? [UIColor mirror_darkYellow] : [UIColor mirror_lightYellow];
        case MirrorColorTypeCellGreen:
            return _interfaceStyle == MirrorUserInterfaceStyleLight ? [UIColor mirror_lightGreen] : [UIColor mirror_darkGreen];
        case MirrorColorTypeCellGreenPulse:
            return _interfaceStyle == MirrorUserInterfaceStyleLight ? [UIColor mirror_darkGreen] : [UIColor mirror_lightGreen];
        case MirrorColorTypeCellBlue:
            return _interfaceStyle == MirrorUserInterfaceStyleLight ? [UIColor mirror_lightBlue] : [UIColor mirror_darkBlue];
        case MirrorColorTypeCellBluePulse:
            return _interfaceStyle == MirrorUserInterfaceStyleLight ? [UIColor mirror_darkBlue] : [UIColor mirror_lightBlue];
        case MirrorColorTypeCellPurple:
            return _interfaceStyle == MirrorUserInterfaceStyleLight ? [UIColor mirror_lightPurple] : [UIColor mirror_darkPurple];
        case MirrorColorTypeCellPurplePulse:
            return _interfaceStyle == MirrorUserInterfaceStyleLight ? [UIColor mirror_darkPurple] : [UIColor mirror_lightPurple];
        case MirrorColorTypeCellGray:
            return _interfaceStyle == MirrorUserInterfaceStyleLight ? [UIColor mirror_lightGray] : [UIColor mirror_darkGray];
        case MirrorColorTypeCellGrayPulse:
            return _interfaceStyle == MirrorUserInterfaceStyleLight ? [UIColor mirror_darkGray] : [UIColor mirror_lightGray];
        default:
            return [UIColor clearColor];
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

+ (UIColor *)mirror_lightBlue
{
    return [UIColor colorWithRed:193/255.0 green:203/255.0 blue:215/255.0 alpha:1]; // 莫兰迪蓝
}

+ (UIColor *)mirror_darkBlue
{
    return [UIColor colorWithRed:134/255.0 green:150/255.0 blue:167/255.0 alpha:1]; // 莫兰迪深蓝
}

+ (UIColor *)mirror_lightPurple
{
    return [UIColor colorWithRed:201/255.0 green:192/255.0 blue:211/255.0 alpha:1]; // 莫兰迪紫
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
