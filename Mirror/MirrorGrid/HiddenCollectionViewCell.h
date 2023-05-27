//
//  HiddenCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HiddenCollectionViewCell : UICollectionViewCell

+ (NSString *)identifier;
- (void)configCellWithTaskname:(NSString *)taskName;

@end

NS_ASSUME_NONNULL_END
