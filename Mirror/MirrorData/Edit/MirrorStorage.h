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

+ (instancetype)sharedInstance;

- (MirrorDataModel *)getTaskFromDB:(NSString *)taskName; //取出某个task

- (void)createTask:(MirrorDataModel *)task;

- (void)deleteTask:(NSString *)taskName;

- (void)archiveTask:(NSString *)taskName;

- (void)editTask:(NSString *)oldName color:(MirrorColorType)newColor name:(NSString *)newName;

- (void)startTask:(NSString *)taskName;

- (void)stopTask:(NSString *)taskName completion:(void (^)(NSString *hint))completion;

- (void)stopAllTasksExcept:(NSString *)exceptTaskName completion:(void (^)(NSString *hint))completion;

- (TaskNameExistsType)taskNameExists:(NSString *)newTaskName;

- (NSMutableDictionary *)retriveMirrorData;

@end

NS_ASSUME_NONNULL_END
