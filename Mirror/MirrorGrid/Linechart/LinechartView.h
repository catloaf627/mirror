//
//  LinechartView.h
//  Mirror
//
//  Created by Yuqing Wang on 2024/2/29.
//

#import <UIKit/UIKit.h>
#import "MirrorDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LinechartView : UIView

- (void)refactorData:(NSMutableArray<NSMutableArray<MirrorDataModel *> *> *)originalData;

@end

NS_ASSUME_NONNULL_END
