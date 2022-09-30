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
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Pink" colorType:MirrorColorTypeCellPink isAddTask:NO],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Orange" colorType:MirrorColorTypeCellOrange isAddTask:NO],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Yellow" colorType:MirrorColorTypeCellYellow isAddTask:NO],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Green" colorType:MirrorColorTypeCellGreen isAddTask:NO],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Teal" colorType:MirrorColorTypeCellTeal isAddTask:NO],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Blue" colorType:MirrorColorTypeCellBlue isAddTask:NO],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Purple" colorType:MirrorColorTypeCellPurple isAddTask:NO],
    [[TimeTrackerTaskModel alloc]initWithTitle:@"Gray" colorType:MirrorColorTypeCellGray isAddTask:NO],
    
    //cell数量不足8的时候必加add task cell
    [[TimeTrackerTaskModel alloc]initWithTitle:nil colorType:nil isAddTask:YES],
    ];
    return tasks;
}

@end
