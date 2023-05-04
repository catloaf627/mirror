//
//  SpanLegend.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/20.
//

#import <UIKit/UIKit.h>
#import "MirrorMacro.h"
#import "MirrorTaskModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SpanLegendDelegate <NSObject> // push viewcontroller用

@end

@interface SpanLegend : UIView

@property (nonatomic, weak) UIViewController<SpanLegendDelegate> *delegate;

- (instancetype)initWithData:(NSMutableArray<MirrorTaskModel *> *)data;
- (void)updateWithData:(NSMutableArray<MirrorTaskModel *> *)data;
- (CGFloat)legendViewHeight;

@end

NS_ASSUME_NONNULL_END
