//
//  TodayDataCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/4.
//

#import <UIKit/UIKit.h>
#import "MirrorDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TodayDataCollectionViewCell : UICollectionViewCell

+ (NSString *)identifier;
- (void)configCellWithModel:(MirrorDataModel *)model;

@end

NS_ASSUME_NONNULL_END
