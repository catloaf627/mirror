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
// 根据datepicker实时更新，找准时机reload collectionview就可，无需update方法
@end

NS_ASSUME_NONNULL_END
