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
    MirrorColorTypeTextHint,                 // 文字备注颜色
    MirrorColorTypeShadow,                   // 阴影颜色
    MirrorColorTypeAddTaskCellBG,            // add task cell的背景颜色
    MirrorColorTypeAddTaskCellPlus,          // add task cell的加号颜色
    MirrorColorTypeCellPink,
    MirrorColorTypeCellPinkPulse,
    MirrorColorTypeCellOrange,
    MirrorColorTypeCellOrangePulse,
    MirrorColorTypeCellYellow,
    MirrorColorTypeCellYellowPulse,
    MirrorColorTypeCellGreen,
    MirrorColorTypeCellGreenPulse,
    MirrorColorTypeCellTeal,
    MirrorColorTypeCellTealPulse,
    MirrorColorTypeCellBlue,
    MirrorColorTypeCellBluePulse,
    MirrorColorTypeCellPurple,
    MirrorColorTypeCellPurplePulse,
    MirrorColorTypeCellGray,
    MirrorColorTypeCellGrayPulse,
};

@interface UIColor (MirrorColor)

+ (UIColor *)mirrorColorNamed:(MirrorColorType)colorType;
+ (MirrorColorType)mirror_getPulseColorType:(MirrorColorType)color;
+ (NSString *)getEmoji:(MirrorColorType)color;
+ (NSString *)getLongEmoji:(MirrorColorType)color;

@end

NS_ASSUME_NONNULL_END
