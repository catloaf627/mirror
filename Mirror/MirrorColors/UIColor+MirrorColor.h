//
//  UIColor+MirrorColor.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MirrorColorType) {
    MirrorColorTypeBackground,         // 主背景色
    MirrorColorTypeIconText,           // 文案/图标颜色
    MirrorColorTypeIconTextHightlight, // 被选中的时候文案/图标颜色
};

@interface UIColor (MirrorColor)

+ (UIColor *)mirrorColorNamed:(MirrorColorType)colorType;

@end

NS_ASSUME_NONNULL_END
