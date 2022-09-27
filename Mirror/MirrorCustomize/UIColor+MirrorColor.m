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
        case MirrorColorTypeCellOrange:
            return [UIColor colorWithRed:248/255.0 green:235/255.0 blue:216/255.0 alpha:1]; // 莫兰迪橘
        case MirrorColorTypeCellYellow:
            return [UIColor colorWithRed:253/255.0 green:249/255.0 blue:238/255.0 alpha:1]; // 莫兰迪黄
        case MirrorColorTypeCellGreen:
            return [UIColor colorWithRed:224/255.0 green:229/255.0 blue:223/255.0 alpha:1]; // 莫兰迪绿
        case MirrorColorTypeCellBlue:
            return [UIColor colorWithRed:193/255.0 green:203/255.0 blue:215/255.0 alpha:1]; // 莫兰迪蓝
        case MirrorColorTypeCellPurple:
            return [UIColor colorWithRed:201/255.0 green:192/255.0 blue:211/255.0 alpha:1]; // 莫兰迪紫
        case MirrorColorTypeCellGray:
            return [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1]; // 莫兰蒂灰
            
        default:
            return [UIColor clearColor];
    }
}

@end
