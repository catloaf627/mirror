//
//  MirrorTimeText.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MirrorTimeText : NSObject

// 哪项没有省略哪项 1h 23m | 1时23分 —> lasted后面的标记
+ (NSString *)XdXhXmXsShortWithstart:(long)start end:(long)end;

// 哪项没有省略哪项 1hour 23 mins | 16天1小时23分钟 —> total后面的标记
+ (NSString *)XdXhXmXsFull:(long)timeInterval;

// 只展示最大项 1.3 days/4.5 hours | 1.3天/4.5小时 —> 柱状图上面的标记
+ (NSString *)XdXhXmXsWithOneMaxUnit:(long)timeInterval;

// Thu, Apr 25, 2023 | 2023年4月23日，周日 -> 柱状图区间切换的标记（一天）
+ (NSString *)YYYYmmddWeekday:(NSDate *)date;

// Apr 25, 2023 | 2023年4月23日 -> 柱状图区间切换的标记（区间）
+ (NSString *)YYYYmmdd:(NSDate *)date;





@end

NS_ASSUME_NONNULL_END
