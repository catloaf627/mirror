//
//  MirrorDefaultDataManager.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/27.
//

#import "MirrorDefaultDataManager.h"

@implementation MirrorDefaultDataManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static MirrorDefaultDataManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[MirrorDefaultDataManager alloc]init];
    });
    return instance;
}

- (NSArray<TimeTrackerTaskModel *> *)mirrorDefaultTimeTrackerData
{
    NSArray<TimeTrackerTaskModel *> *tasks = @[
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Study" color:[UIColor yellowColor]],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Sleep" color:[UIColor blueColor]],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Social" color:[UIColor systemPinkColor]],
    ];
    return tasks;
}

@end
