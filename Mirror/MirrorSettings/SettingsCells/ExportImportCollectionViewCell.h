//
//  ExportImportCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/30.
//

#import "ToggleCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExportImportCollectionViewCell : ToggleCollectionViewCell

+ (NSString *)identifier;
- (void)configCell;

@end

NS_ASSUME_NONNULL_END
