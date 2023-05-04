//
//  MirrorStorage.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/10/24.
//

#import <Foundation/Foundation.h>
#import "MirrorDataModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TaskNameExistsType) {
    TaskNameExistsTypeValid, // 库里没有这个taskname，taskname合格
    TaskNameExistsTypeExistsInCurrentTasks,
    TaskNameExistsTypeExistsInArchivedTasks,
};

// ❗️❗️❗️这里的数据结构是词典结构，因为主要用于寻找或者编辑某个task（与之相对的是MirrorDataManager使用的是数组结构，因为涉及到顺序的问题）
@interface MirrorStorage : NSObject

// 业务用

+ (NSMutableArray<MirrorTaskModel *> *)tasksWithAddNew;

+ (void)createTask:(MirrorTaskModel *)task;

+ (void)deleteTask:(NSString *)taskName;

+ (void)archiveTask:(NSString *)taskName;

+ (void)cancelArchiveTask:(NSString *)taskName;

+ (void)editTask:(NSString *)oldName name:(NSString *)newName;

+ (void)editTask:(NSString *)taskName color:(MirrorColorType)color;

+ (void)reorderTasks:(NSMutableArray <MirrorTaskModel *> *)taskArray;

+ (void)savePeriodWithTaskname:(NSString *)taskName startAt:(NSDate *)startDate endAt:(NSDate *)endDate; // 跳过start->stop，直接保存

+ (void)startTask:(NSString *)taskName at:(NSDate *)accurateDate;

+ (void)stopTask:(NSString *)taskName at:(NSDate *)accurateDate;

+ (TaskNameExistsType)taskNameExists:(NSString *)newTaskName;

// Period

+ (void)deletePeriodAtIndex:(NSInteger)index;

+ (void)editPeriodIsStartTime:(BOOL)isStartTime to:(long)timestamp periodIndex:(NSInteger)index;

// 每次冷启检查时区是不是变了，变了需要改数据库

+ (void)changeDataWithTimezoneGap:(NSInteger)timezoneGap;

// Retrive
+ (NSMutableArray<MirrorTaskModel *> *)retriveMirrorTasks;

+ (NSMutableArray<MirrorRecordModel *> *)retriveMirrorRecords;

// 取出一个taskmodel
+ (MirrorTaskModel *)getTaskModelFromDB:(NSString *)taskName;

// 取出一个任务从古至今的所有records
+ (MirrorDataModel *)getAllTaskRecords:(NSString *)taskNam;

// 取出从startTime到endTime的所有条record
+ (NSMutableArray<MirrorRecordModel *> *)getAllRecordsWithStart:(long)startTime end:(long)endTime;

// 取出从startTime到endTime的所有条record，并按照taskname存储
+ (NSMutableArray<MirrorDataModel *> *)getAllRecordsInTaskOrderWithStart:(long)startTime end:(long)endTime;

@end

NS_ASSUME_NONNULL_END
