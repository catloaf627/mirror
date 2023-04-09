//
//  TimeTrackingLabel.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/8.
//

#import <UIKit/UIKit.h>
#import "MirrorDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TimeTrackingLabelProtocol <NSObject>

- (void)destroyTimeTrackingLabel;

@end


@interface TimeTrackingLabel : UILabel

@property (nonatomic, strong) NSString *identifier; // 将taskname作为identifier
@property (nonatomic, strong) UIView<TimeTrackingLabelProtocol> *delegate;

- (instancetype)initWithTask:(NSString *)taskName;

@end

NS_ASSUME_NONNULL_END
