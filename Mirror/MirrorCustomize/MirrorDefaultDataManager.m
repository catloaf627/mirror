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

- (NSMutableArray<TimeTrackerTaskModel *> *)mirrorDefaultTimeTrackerData
{
    NSMutableArray<TimeTrackerTaskModel *> *tasks = @[
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Pink" color:[UIColor mirrorColorNamed:MirrorColorTypeCellPink] pulseColor:[UIColor mirrorColorNamed:MirrorColorTypeCellPinkPulse] isAddTask:NO],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Orange" color:[UIColor mirrorColorNamed:MirrorColorTypeCellOrange] pulseColor:[UIColor mirrorColorNamed:MirrorColorTypeCellOrangePulse] isAddTask:NO],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Yellow" color:[UIColor mirrorColorNamed:MirrorColorTypeCellYellow] pulseColor:[UIColor mirrorColorNamed:MirrorColorTypeCellYellowPulse] isAddTask:NO],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Green" color:[UIColor mirrorColorNamed:MirrorColorTypeCellGreen] pulseColor:[UIColor mirrorColorNamed:MirrorColorTypeCellGreenPulse] isAddTask:NO],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Teal" color:[UIColor mirrorColorNamed:MirrorColorTypeCellTeal] pulseColor:[UIColor mirrorColorNamed:MirrorColorTypeCellTealPulse] isAddTask:NO],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Blue" color:[UIColor mirrorColorNamed:MirrorColorTypeCellBlue] pulseColor:[UIColor mirrorColorNamed:MirrorColorTypeCellBluePulse] isAddTask:NO],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Purple" color:[UIColor mirrorColorNamed:MirrorColorTypeCellPurple] pulseColor:[UIColor mirrorColorNamed:MirrorColorTypeCellPurplePulse] isAddTask:NO],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Gray" color:[UIColor mirrorColorNamed:MirrorColorTypeCellGray] pulseColor:[UIColor mirrorColorNamed:MirrorColorTypeCellGrayPulse] isAddTask:NO],
    
    //cell数量不足8的时候必加add task cell
    [[TimeTrackerTaskModel alloc]initWithTitle:nil color:nil pulseColor:nil isAddTask:YES],
    ];
    return tasks;
}

@end
