//
//  PeriodsTotalHeaderCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PeriodsTotalHeaderCell : UICollectionViewCell

- (void)configWithTasknames:(NSArray<NSString *> *)taskNames periodIndexes:(NSArray *)indexes;

@end

NS_ASSUME_NONNULL_END
