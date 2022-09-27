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
    switch (colorType) {
        case MirrorColorTypeBackground:
            return [UIColor whiteColor];
        case MirrorColorTypeTabbarIconText:
            return [UIColor grayColor];
        case MirrorColorTypeTabbarIconTextHightlight:
            return [UIColor blackColor];
        case MirrorColorTypeText:
            return [UIColor blackColor];
        case MirrorColorTypeCellPink:
            return [UIColor colorWithRed:224/255.0 green:205/255.0 blue:207/255.0 alpha:1]; // 莫兰迪粉
        case MirrorColorTypeCellPinkPulse:
            return [UIColor colorWithRed:177/255.0 green:122/255.0 blue:125/255.0 alpha:1]; // 莫兰迪深粉
        case MirrorColorTypeCellOrange:
            return [UIColor colorWithRed:248/255.0 green:235/255.0 blue:216/255.0 alpha:1]; // 莫兰迪橘
        case MirrorColorTypeCellOrangePulse:
            return [UIColor colorWithRed:160/255.0 green:106/255.0 blue:80/255.0 alpha:1]; // 莫兰迪深橘
        case MirrorColorTypeCellYellow:
            return [UIColor colorWithRed:253/255.0 green:249/255.0 blue:238/255.0 alpha:1]; // 莫兰迪黄
        case MirrorColorTypeCellYellowPulse:
            return [UIColor colorWithRed:166/255.0 green:142/255.0 blue:118/255.0 alpha:1]; // 莫兰迪深黄（棕）
        case MirrorColorTypeCellGreen:
            return [UIColor colorWithRed:224/255.0 green:229/255.0 blue:223/255.0 alpha:1]; // 莫兰迪绿
        case MirrorColorTypeCellGreenPulse:
            return [UIColor colorWithRed:122/255.0 green:103/255.0 blue:71/255.0 alpha:1]; // 莫兰迪深绿
        case MirrorColorTypeCellBlue:
            return [UIColor colorWithRed:193/255.0 green:203/255.0 blue:215/255.0 alpha:1]; // 莫兰迪蓝
        case MirrorColorTypeCellBluePulse:
            return [UIColor colorWithRed:134/255.0 green:150/255.0 blue:167/255.0 alpha:1]; // 莫兰迪深蓝
        case MirrorColorTypeCellPurple:
            return [UIColor colorWithRed:201/255.0 green:192/255.0 blue:211/255.0 alpha:1]; // 莫兰迪紫
        case MirrorColorTypeCellPurplePulse:
            return [UIColor colorWithRed:105/255.0 green:100/255.0 blue:123/255.0 alpha:1]; // 莫兰迪深紫
        case MirrorColorTypeCellGray:
            return [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1]; // 莫兰蒂灰
        case MirrorColorTypeCellGrayPulse:
            return [UIColor colorWithRed:147/255.0 green:147/255.0 blue:145/255.0 alpha:1]; // 莫兰蒂深灰
            
        default:
            return [UIColor clearColor];
    }
}

@end
