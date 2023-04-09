//
//  DataEntranceCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, DataEntranceType) {
    DataEntranceTypeToday, // 库里没有这个taskname，taskname合格
    DataEntranceTypeThisWeek,
    DataEntranceTypeThisMonth,
    DataEntranceTypeThisYear,
};

@interface DataEntranceCollectionViewCell : UICollectionViewCell

+ (NSString *)identifier;
- (void)configCellWithType:(DataEntranceType)type;

@end

NS_ASSUME_NONNULL_END
