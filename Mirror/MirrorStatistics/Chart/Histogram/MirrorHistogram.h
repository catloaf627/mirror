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

@protocol MirrorHistogramDelegate <NSObject>  // push viewcontroller用

@end

@interface MirrorHistogram : UIView

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) UIViewController<MirrorHistogramDelegate> *delegate;
- (instancetype)initWithDatePicker:(UIDatePicker *)datePicker;
@end

NS_ASSUME_NONNULL_END
