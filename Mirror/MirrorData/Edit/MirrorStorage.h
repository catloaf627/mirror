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

- (void)createTask:(MirrorDataModel *)task;

- (void)deleteTask:(MirrorDataModel *)task;

- (void)archiveTask:(MirrorDataModel *)task;

- (void)editTask:(MirrorDataModel *)task color:(MirrorColorType)newColor name:(NSString *)newName;

- (void)startTask:(MirrorDataModel *)task;

- (void)stopTask:(MirrorDataModel *)task;

- (void)stopAllTasks;

- (void)addTask:(MirrorDataModel *)task onDate:(NSString *)date time:(NSInteger)seconds;

- (TaskNameExistsType)taskNameExists:(NSString *)newTaskName;

- (void)fakeData;

@end

NS_ASSUME_NONNULL_END
