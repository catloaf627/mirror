//
//  TaskPeriodCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/15.
//

#import <UIKit/UIKit.h>
#import "MirrorDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TaskPeriodCollectionViewCell : UICollectionViewCell

+ (NSString *)identifier;

- (void)configWithTask:(MirrorDataModel *)task index:(NSInteger)index;


@end

NS_ASSUME_NONNULL_END
