//
//  LegendCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/15.
//

#import <UIKit/UIKit.h>
#import "MirrorDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LegendCollectionViewCell : UICollectionViewCell

+ (NSString *)identifier;

- (void)configCellWithTask:(MirrorDataModel *)task;

@end

NS_ASSUME_NONNULL_END
