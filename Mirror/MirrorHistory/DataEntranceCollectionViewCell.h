//
//  DataEntranceCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataEntranceCollectionViewCell : UICollectionViewCell

+ (NSString *)identifier;
- (void)configCellWithIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
