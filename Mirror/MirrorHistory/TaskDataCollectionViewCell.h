//
//  TaskDataCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/10/27.
//

#import <UIKit/UIKit.h>
#import "TimeTrackerTaskModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TaskDataCollectionViewCell : UICollectionViewCell

+ (NSString *)identifier;
- (void)configCellWithModel:(TimeTrackerTaskModel *)model;

@end

NS_ASSUME_NONNULL_END
