//
//  TaskInfoCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TaskInfoCollectionViewCell : UICollectionViewCell

+ (NSString *)identifier;

- (void)configWithTaskname:(NSString *)taskName;

@end

NS_ASSUME_NONNULL_END
