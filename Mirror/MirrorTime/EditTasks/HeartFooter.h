//
//  HeartFooter.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ExportJsonProtocol <NSObject>

@end

@interface HeartFooter : UICollectionViewCell

@property (nonatomic, weak) UIViewController<ExportJsonProtocol> *delegate;
- (void)config;

@end

NS_ASSUME_NONNULL_END
