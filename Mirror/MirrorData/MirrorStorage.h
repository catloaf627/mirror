//
//  MirrorStorage.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/10/24.
//

#import <Foundation/Foundation.h>
#import "TimeTrackerTaskModel.h"


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TaskNameExistsType) {
    TaskNameExistsTypeValid, // 库里没有这个taskname，taskname合格
    TaskNameExistsTypeExistsInCurrentTasks,
    TaskNameExistsTypeExistsInArchivedTasks,
};

@interface MirrorStorage : NSObject

+ (instancetype)sharedInstance;

- (void)createTask:(TimeTrackerTaskModel *)task;

- (void)deleteTask:(TimeTrackerTaskModel *)task;

- (void)archiveTask:(TimeTrackerTaskModel *)task;

- (void)editTask:(TimeTrackerTaskModel *)task color:(MirrorColorType)newColor name:(NSString *)newName;

- (void)startTask:(TimeTrackerTaskModel *)task;

- (void)stopTask:(TimeTrackerTaskModel *)task;

- (void)stopAllTasks;

- (void)addTask:(TimeTrackerTaskModel *)task onDate:(NSString *)date time:(NSInteger)seconds;

- (TaskNameExistsType)taskNameExists:(NSString *)newTaskName;

- (NSInteger)getTimeFromTask:(TimeTrackerTaskModel *)task OnDate:(NSString *)date;

- (NSInteger)getTotalTimeFromTask:(TimeTrackerTaskModel *)task;

- (void)fakeData;

@end

NS_ASSUME_NONNULL_END
