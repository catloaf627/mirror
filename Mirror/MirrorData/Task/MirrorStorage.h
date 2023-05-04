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

@interface MirrorStorage : NSObject

// TimeVC用

+ (NSString *)isGoingOnTask; // 返回为空意味着没有正在进行的task

+ (NSMutableArray<MirrorTaskModel *> *)tasksWithoutArchiveWithAddNew;

// Actions

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

/*
 取出一个taskmodel
 {英语, 未归档, 粉色, 2023年5月1日创建}
 适用场景：想要得到归档信息、颜色信息、创建日期
 */
+ (MirrorTaskModel *)getTaskModelFromDB:(NSString *)taskName;

/*
 取出【某任务】从古至今的所有records
 {[此record在总表中的index], 英语, 05:00, 06:00}, {[此record在总表中的index], 英语, 08:00, 09:00}, {[此record在总表中的index], 英语, 11:00, 12:00}...
 适用场景：某任务totaltime、某任务所有records页面
 */
+ (NSMutableArray<MirrorRecordModel *> *)getAllTaskRecords:(NSString *)taskName;

/*
 取出【所有任务】从【某时间】到【某时间】的所有records
 {[此record在总表中的index], 英语, 05:00, 06:00}, {[此record在总表中的index], 数学, 06:00, 07:00}..
 适用场景：目前只有today的record展示用到这个方法
 */
+ (NSMutableArray<MirrorRecordModel *> *)getAllRecordsWithStart:(long)startTime end:(long)endTime;

/*
 取出【所有任务】从【某时间】到【某时间】的所有records，并按照优先级排序 （如顺序为数学、英语）
 {[此record在总表中的index], 数学, 06:00, 07:00}, {[此record在总表中的index], 英语, 05:00, 06:00}...
 适用场景：grid，饼图，柱形图，legend
 */
+ (NSMutableArray<MirrorDataModel *> *)getAllRecordsInTaskOrderWithStart:(long)startTime end:(long)endTime;

@end

NS_ASSUME_NONNULL_END
