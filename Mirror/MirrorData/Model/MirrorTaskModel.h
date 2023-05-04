//
//  MirrorTaskModel.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIColor+MirrorColor.h"

NS_ASSUME_NONNULL_BEGIN

@interface MirrorTaskModel : NSObject <NSCoding, NSSecureCoding>

// 存在本地
@property (nonatomic, strong) NSString *taskName;
@property (nonatomic, assign) BOOL isArchived;
@property (nonatomic, assign) MirrorColorType color;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *periods;
@property (nonatomic, assign) long createdTime;
@property (nonatomic, assign) NSInteger priority;
// 通过本地计算
@property (nonatomic, assign) BOOL isOngoing;
// 外部赋值
@property (nonatomic, assign) BOOL isAddTaskModel;

- (instancetype)initWithTitle:(NSString *)taskName createdTime:(long)createTime order:(NSInteger)order colorType:(MirrorColorType)colorType isArchived:(BOOL)isArchived periods:(NSMutableArray<NSMutableArray *> *)periods isAddTask:(BOOL)isAddTaskModel;


@end

NS_ASSUME_NONNULL_END
