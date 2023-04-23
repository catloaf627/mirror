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
typedef NS_ENUM(NSInteger, TaskSavedType) {
    TaskSavedTypeNone,
    TaskSavedTypeSaved,
    TaskSavedTypeTooShort,
    TaskSavedTypeError,
};

// ❗️❗️❗️这里的数据结构是词典结构，因为主要用于寻找或者编辑某个task（与之相对的是MirrorDataManager使用的是数组结构，因为涉及到顺序的问题）
@interface MirrorStorage : NSObject

// 业务用

+ (MirrorDataModel *)getTaskFromDB:(NSString *)taskName; //取出某个task

+ (MirrorDataModel *)getOngoingTaskFromDB; // 取出正在进行中的task

+ (void)createTask:(MirrorDataModel *)task;

+ (void)deleteTask:(NSString *)taskName;

+ (void)archiveTask:(NSString *)taskName;

+ (void)editTask:(NSString *)oldName color:(MirrorColorType)newColor name:(NSString *)newName;

+ (void)startTask:(NSString *)taskName at:(NSDate *)accurateDate periodIndex:(NSInteger)index;

+ (void)stopTask:(NSString *)taskName at:(NSDate *)accurateDate periodIndex:(NSInteger)index;

+ (void)stopAllTasksExcept:(NSString *)exceptTaskName;

+ (TaskNameExistsType)taskNameExists:(NSString *)newTaskName;

// Period

+ (void)deletePeriodWithTaskname:(NSString *)taskName periodIndex:(NSInteger)index;

+ (void)editPeriodIsStartTime:(BOOL)isStartTime to:(long)timestamp withTaskname:(NSString *)taskName periodIndex:(NSInteger)index;

// MirrorDataManager用

+ (NSMutableDictionary *)retriveMirrorData;

// Log

+ (void)printTask:(MirrorDataModel *)task info:(NSString *)info;

@end

NS_ASSUME_NONNULL_END
