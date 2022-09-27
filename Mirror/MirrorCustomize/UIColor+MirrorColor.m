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
            return [UIColor whiteColor]; //gizmo 暂时写死
        case MirrorColorTypeIconText:
            return [UIColor grayColor]; //gizmo 暂时写死
        case MirrorColorTypeIconTextHightlight:
            return [UIColor blackColor]; //gizmo 暂时写死
            
        default:
            break;
    }
}

@end
