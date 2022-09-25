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
        case MirrorColorTypeIconText:
            return [UIColor grayColor];
        case MirrorColorTypeIconTextHightlight:
            return [UIColor blackColor];
            
        default:
            break;
    }
}

@end
