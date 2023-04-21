//
//  TodayPeriodCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PushEditPeriodSheetForTodayProtocol <NSObject>

- (void)pushEditPeriodSheet:(UIViewController *)editVC;

@end

@interface TodayPeriodCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) UIViewController<PushEditPeriodSheetForTodayProtocol> *delegate;
+ (NSString *)identifier;
- (void)configWithTaskname:(NSString *)taskName periodIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
