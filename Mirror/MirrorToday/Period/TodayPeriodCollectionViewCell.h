//
//  TodayPeriodCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EditPeriodForTodayProtocol <NSObject>

@end

@interface TodayPeriodCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) UIViewController<EditPeriodForTodayProtocol> *delegate;
+ (NSString *)identifier;
- (void)configWithTaskname:(NSString *)taskName periodIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
