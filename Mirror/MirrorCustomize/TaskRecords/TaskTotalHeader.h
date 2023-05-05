//
//  TaskTotalHeader.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TaskTotalHeader : UICollectionViewCell

- (void)config; // 所有record的header

- (void)configWithTaskname:(NSString *)taskname; // 某一task所有record的header

@end

NS_ASSUME_NONNULL_END
