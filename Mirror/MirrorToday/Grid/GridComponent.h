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
@property (nonatomic, strong) NSMutableArray<MirrorDataModel *> *thatDayData;

- (instancetype)initWithValid:(BOOL)isValid thatDayData:(NSMutableArray<MirrorDataModel *> *)thatDayData;

@end

NS_ASSUME_NONNULL_END
