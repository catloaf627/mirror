//
//  SpanHistogram.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/20.
//

#import <UIKit/UIKit.h>
#import "MirrorMacro.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SpanHistogramDelegate <NSObject>  // push viewcontroller用 + update label

- (void)updateSpanText:(NSString *)text;

@end

@interface SpanHistogram : UIView

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) UIViewController<SpanHistogramDelegate> *delegate;

- (instancetype)initWithSpanType:(SpanType)spanType offset:(NSInteger)offset;
- (void)updateWithSpanType:(SpanType)spanType offset:(NSInteger)offset;

@end

NS_ASSUME_NONNULL_END
