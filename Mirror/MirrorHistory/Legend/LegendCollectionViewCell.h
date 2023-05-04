//
//  LegendCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/15.
//

#import <UIKit/UIKit.h>
#import "MirrorTaskModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LegendCollectionViewCell : UICollectionViewCell

+ (NSString *)identifier;

- (void)configCellWithTaskname:(NSString *)taskName;

@end

NS_ASSUME_NONNULL_END
