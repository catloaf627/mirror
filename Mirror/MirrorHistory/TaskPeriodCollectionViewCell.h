//
//  TaskPeriodCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TaskPeriodCollectionViewCell : UICollectionViewCell

+ (NSString *)identifier;

- (void)configWithStart:(long)start end:(long)end color:(UIColor *)color;


@end

NS_ASSUME_NONNULL_END
