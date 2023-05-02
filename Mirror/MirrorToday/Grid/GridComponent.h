//
//  GridComponent.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/2.
//

#import <Foundation/Foundation.h>
#import "MirrorDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GridComponent : NSObject

@property (nonatomic, assign) BOOL isValid;
@property (nonatomic, strong) NSMutableArray<MirrorDataModel *> *thatDayTasks;

- (instancetype)initWithValid:(BOOL)isValid thatDayTasks:(NSMutableArray<MirrorDataModel *> *)thatDayTasks;

@end

NS_ASSUME_NONNULL_END
