//
//  WeekStartsOnCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/11.
//

#import "ToggleCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WeekStartsOnCollectionViewCell : ToggleCollectionViewCell

+ (NSString *)identifier;
- (void)configCell;

@end

NS_ASSUME_NONNULL_END
