//
//  UIColor+MirrorColor.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, MirrorUserInterfaceStyle) {
    MirrorUserInterfaceStyleLight,
    MirrorUserInterfaceStyleDark,
};

typedef NS_ENUM(NSInteger, MirrorColorType) {
    MirrorColorTypeBackground,               // 主背景色
    MirrorColorTypeTabbarIconText,           // tabbar item 未选中的颜色
    MirrorColorTypeTabbarIconTextHightlight, // tabbar item 被选中的颜色
    MirrorColorTypeText,                     // 文字颜色
    MirrorColorTypeShadow,                   // 阴影颜色
    MirrorColorTypeCellPink,
    MirrorColorTypeCellPinkPulse,
    MirrorColorTypeCellOrange,
    MirrorColorTypeCellOrangePulse,
    MirrorColorTypeCellYellow,
    MirrorColorTypeCellYellowPulse,
    MirrorColorTypeCellGreen,
    MirrorColorTypeCellGreenPulse,
    MirrorColorTypeCellBlue,
    MirrorColorTypeCellBluePulse,
    MirrorColorTypeCellPurple,
    MirrorColorTypeCellPurplePulse,
    MirrorColorTypeCellGray,
    MirrorColorTypeCellGrayPulse,
};

@interface UIColor (MirrorColor)

+ (void)switchTheme;
+ (UIColor *)mirrorColorNamed:(MirrorColorType)colorType;

@end

NS_ASSUME_NONNULL_END
