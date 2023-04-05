//
//  MirrorTool.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import "MirrorTool.h"

@implementation MirrorTool

+ (void)printNow
{
    // Date
    NSDate *dateNow = [NSDate now];
    // Date in timestamp (for machine)
    NSString *timeStamp = [NSString stringWithFormat:@"%ld", (long)[dateNow timeIntervalSince1970]]; //全app默认使用1970
    NSLog(@"Shanghai time %@", timeStamp);
    // Date in formatter (for people)
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // hh是12小时制，HH是24小时制
    NSTimeZone *timezone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timezone];
    NSLog(@"Shanghai time: %@", [formatter stringFromDate:dateNow]);
}

@end
