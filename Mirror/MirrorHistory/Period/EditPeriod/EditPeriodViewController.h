//
//  EditPeriodViewController.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EditPeriodViewController : UIViewController

- (instancetype)initWithTaskname:(NSString *)taskName periodIndex:(NSInteger)periodIndex isStartTime:(BOOL)isStartTime;

@end

NS_ASSUME_NONNULL_END
