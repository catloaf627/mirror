//
//  MirrorTool.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MirrorTool : NSObject

+ (NSString *)timeFromDate:(NSDate *)date printTimeStamp:(BOOL)printTimeStamp;
+ (NSString *)timeFromTimestamp:(long)timestamp printTimeStamp:(BOOL)printTimeStamp;

@end

NS_ASSUME_NONNULL_END
