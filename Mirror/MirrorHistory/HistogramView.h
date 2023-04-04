//
//  HistogramView.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HistogramView : UIView

- (void)reloadHistogramView; // 切换柱状图类型的时候reload，如当用户将主要展示的柱状图类型从today改成了this month，这时候需要把DataViewController里的histogramView reload一下才能udpate

@end

NS_ASSUME_NONNULL_END
