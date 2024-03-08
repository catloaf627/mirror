//
//  LineChartCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2024/3/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LineChartCollectionViewCell : UICollectionViewCell

+ (NSString *)identifier;
- (void)configCellWithOnedaydata:(NSMutableDictionary<NSString *, NSNumber *> *)onedaydata
                     leftdaydata:(NSMutableDictionary<NSString *, NSNumber *> *)leftdaydata
                    rightdaydata:(NSMutableDictionary<NSString *, NSNumber *> *)rightdaydata
                         maxtime:(long)maxtime;

@end

NS_ASSUME_NONNULL_END
