//
//  GridComponent.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/2.
//

#import <Foundation/Foundation.h>
#import "MirrorTaskModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GridComponent : NSObject

@property (nonatomic, assign) BOOL isValid;
@property (nonatomic, strong) NSMutableArray<MirrorTaskModel *> *thatDayTasks;

- (instancetype)initWithValid:(BOOL)isValid thatDayTasks:(NSMutableArray<MirrorTaskModel *> *)thatDayTasks;

@end

NS_ASSUME_NONNULL_END
