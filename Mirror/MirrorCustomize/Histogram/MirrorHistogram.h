//
//  MirrorHistogram.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MirrorHistogramType) {
    MirrorHistogramTypeToday, // 库里没有这个taskname，taskname合格
    MirrorHistogramTypeThisMonth,
    MirrorHistogramTypeThisYear,
    MirrorHistogramTypeAll,
};

@interface MirrorHistogram : UIView

- (instancetype)initWithType:(MirrorHistogramType)type;

@end

NS_ASSUME_NONNULL_END
