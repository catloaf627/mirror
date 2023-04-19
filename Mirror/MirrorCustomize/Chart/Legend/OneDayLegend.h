//
//  OneDayLegend.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OneDayLegendDelegate <NSObject> // push viewcontroller用

@end

@interface OneDayLegend : UIView

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) UIViewController<OneDayLegendDelegate> *delegate;

- (instancetype)initWithDatePicker:(UIDatePicker *)datePicker;
- (CGFloat)legendViewHeight;
@end

NS_ASSUME_NONNULL_END
