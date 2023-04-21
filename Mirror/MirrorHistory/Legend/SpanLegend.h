//
//  SpanLegend.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/20.
//

#import <UIKit/UIKit.h>
#import "MirrorMacro.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SpanLegendDelegate <NSObject> // push viewcontroller用

@end

@interface SpanLegend : UIView

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) UIViewController<SpanLegendDelegate> *delegate;

- (instancetype)initWithSpanType:(SpanType)spanType offset:(NSInteger)offset;
- (void)updateWithSpanType:(SpanType)spanType offset:(NSInteger)offset;
- (CGFloat)legendViewHeight;

@end

NS_ASSUME_NONNULL_END
