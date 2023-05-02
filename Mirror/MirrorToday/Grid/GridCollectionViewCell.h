//
//  GridCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/2.
//

#import <UIKit/UIKit.h>
#import "GridComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface GridCollectionViewCell : UICollectionViewCell

+ (NSString *)identifier;
- (void)configWithGridComponent:(GridComponent *)component isSelected:(BOOL)isSelected;

@end

NS_ASSUME_NONNULL_END
