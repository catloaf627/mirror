//
//  ImmersiveCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/10/24.
//

#import "ToggleCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImmersiveCollectionViewCell : ToggleCollectionViewCell

+ (NSString *)identifier;
- (void)configCell;

@end

NS_ASSUME_NONNULL_END
