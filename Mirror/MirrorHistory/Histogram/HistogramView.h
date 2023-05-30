//
//  HistogramView.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/20.
//

#import <UIKit/UIKit.h>
#import "MirrorMacro.h"
#import "MirrorDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HistogramDelegate <NSObject>  // 让对应的legend闪一下

- (void)twinkleTaskname:(NSString *)taskname;

@end

@interface HistogramView : UIView

@property (nonatomic, weak) UIView<HistogramDelegate> *delegate;

- (instancetype)initWithData:(NSMutableArray<MirrorDataModel *> *)data;
- (void)updateWithData:(NSMutableArray<MirrorDataModel *> *)data;

@end

NS_ASSUME_NONNULL_END
