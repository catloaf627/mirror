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
        default:
            break;
    }
}

@end
