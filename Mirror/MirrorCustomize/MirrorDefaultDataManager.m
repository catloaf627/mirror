//
//  MirrorDefaultDataManager.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/27.
//

#import "MirrorDefaultDataManager.h"
#import "UIColor+MirrorColor.h"

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
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Pink" color:[UIColor mirrorColorNamed:MirrorColorTypeCellPink]],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Orange" color:[UIColor mirrorColorNamed:MirrorColorTypeCellOrange]],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Yellow" color:[UIColor mirrorColorNamed:MirrorColorTypeCellYellow]],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Green" color:[UIColor mirrorColorNamed:MirrorColorTypeCellGreen]],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Blue" color:[UIColor mirrorColorNamed:MirrorColorTypeCellBlue]],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Purple" color:[UIColor mirrorColorNamed:MirrorColorTypeCellPurple]],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Gray" color:[UIColor mirrorColorNamed:MirrorColorTypeCellGray]],
    ];
    return tasks;
}

@end
