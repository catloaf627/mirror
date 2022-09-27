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
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Pink" color:[UIColor mirrorColorNamed:MirrorColorTypeCellPink] pulseColor:[UIColor mirrorColorNamed:MirrorColorTypeCellPinkPulse]],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Orange" color:[UIColor mirrorColorNamed:MirrorColorTypeCellOrange] pulseColor:[UIColor mirrorColorNamed:MirrorColorTypeCellOrangePulse]],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Yellow" color:[UIColor mirrorColorNamed:MirrorColorTypeCellYellow] pulseColor:[UIColor mirrorColorNamed:MirrorColorTypeCellYellowPulse]],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Green" color:[UIColor mirrorColorNamed:MirrorColorTypeCellGreen] pulseColor:[UIColor mirrorColorNamed:MirrorColorTypeCellGreenPulse]],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Blue" color:[UIColor mirrorColorNamed:MirrorColorTypeCellBlue] pulseColor:[UIColor mirrorColorNamed:MirrorColorTypeCellBluePulse]],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Purple" color:[UIColor mirrorColorNamed:MirrorColorTypeCellPurple] pulseColor:[UIColor mirrorColorNamed:MirrorColorTypeCellPurplePulse]],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Gray" color:[UIColor mirrorColorNamed:MirrorColorTypeCellGray] pulseColor:[UIColor mirrorColorNamed:MirrorColorTypeCellGrayPulse]],
    ];
    return tasks;
}

@end
