//
//  TimeTrackerTaskModel.h
//  Mirror
//
//  Created by wangyuqing on 2022/9/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIColor+MirrorColor.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimeTrackerTaskModel : NSObject

@property (nonatomic, assign) BOOL isAddTaskModel;
@property (nonatomic, strong) NSString *taskName;
@property (nonatomic, strong) NSString *timeInfo;
@property (nonatomic, assign) MirrorColorType color;
@property (nonatomic, assign) BOOL isOngoing;

- (instancetype)initWithTitle:(NSString *)taskName colorType:(MirrorColorType)colorType isAddTask:(BOOL)isAddTaskModel;
- (void)didStartTask;
- (void)didStopTask;

@end

NS_ASSUME_NONNULL_END
