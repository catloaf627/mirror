//
//  MirrorHistogram.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MirrorHistogramType) {
    MirrorHistogramTypeToday,
    MirrorHistogramTypeThisWeek,
    MirrorHistogramTypeThisMonth,
    MirrorHistogramTypeThisYear,
};

@interface MirrorHistogram : UIView

@property (nonatomic, strong) UICollectionView *collectionView;

@end

NS_ASSUME_NONNULL_END
