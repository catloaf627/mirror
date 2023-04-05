//
//  MirrorDataModel.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIColor+MirrorColor.h"

NS_ASSUME_NONNULL_BEGIN

@interface MirrorDataModel : NSObject

@property (nonatomic, assign) BOOL isAddTaskModel;
@property (nonatomic, assign) BOOL isArchived;
@property (nonatomic, strong) NSString *taskName;
@property (nonatomic, strong) NSString *timeInfo;
@property (nonatomic, assign) MirrorColorType color;
@property (nonatomic, assign) BOOL isOngoing;
@property (nonatomic, assign) NSDate *startTime; //只有isOngoing为YES的时候才会用到startTime

- (instancetype)initWithTitle:(NSString *)taskName colorType:(MirrorColorType)colorType isArchived:(BOOL)isArchived isOngoing:(BOOL)isOngoing isAddTask:(BOOL)isAddTaskModel;
- (void)didStartTask;
- (void)didStopTask;


@end

NS_ASSUME_NONNULL_END
