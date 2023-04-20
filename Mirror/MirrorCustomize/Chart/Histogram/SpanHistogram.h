//
//  SpanHistogram.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SpanType) {
    SpanTypeWeek,
    SpanTypeMonth,
    SpanTypeYear,
};

@protocol SpanHistogramDelegate <NSObject>  // push viewcontroller用

@end

@interface SpanHistogram : UIView

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) UIViewController<SpanHistogramDelegate> *delegate;

@property (nonatomic, strong) NSString *startDate; // 对外update label用
@property (nonatomic, strong) NSString *endDate; // 对外update label用

- (instancetype)initWithSpanType:(SpanType)spanType offset:(NSInteger)offset;
- (void)updateWithSpanType:(SpanType)spanType offset:(NSInteger)offset;

@end

NS_ASSUME_NONNULL_END
