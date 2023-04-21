//
//  MirrorPiechart.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MirrorPiechart : UIView

- (instancetype)initTodayWithWidth:(CGFloat)width;
- (void)updateTodayWithWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
