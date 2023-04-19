//
//  OneDayHistogram.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OneDayHistogramDelegate <NSObject>  // push viewcontroller用

@end

@interface OneDayHistogram : UIView

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) UIViewController<OneDayHistogramDelegate> *delegate;
- (instancetype)initWithDatePicker:(UIDatePicker *)datePicker;
@end

NS_ASSUME_NONNULL_END
