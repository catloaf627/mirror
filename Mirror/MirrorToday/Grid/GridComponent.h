//
//  GridComponent.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/2.
//

#import <Foundation/Foundation.h>
#import "MirrorChartModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GridComponent : NSObject

@property (nonatomic, assign) BOOL isValid;
@property (nonatomic, strong) NSMutableArray<MirrorChartModel *> *thatDayData;

- (instancetype)initWithValid:(BOOL)isValid thatDayData:(NSMutableArray<MirrorChartModel *> *)thatDayData;

@end

NS_ASSUME_NONNULL_END
