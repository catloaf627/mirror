//
//  MirrorLanguage.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/27.
//

#import "MirrorLanguage.h"

@implementation MirrorLanguage

+ (void)switchLanguage
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredChinese"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MirrorUserPreferredChinese"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MirrorUserPreferredChinese"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MirrorSwitchLanguageNotification" object:nil];
}

+ (BOOL)isChinese
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredChinese"]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)mirror_stringWithKey:(NSString *)key
{
    NSMutableDictionary *mirrorDict = [NSMutableDictionary new];
    // tabs
    [mirrorDict setValue:@[@"Me", @"我的"] forKey:@"me"];
    [mirrorDict setValue:@[@"Start", @"冲鸭"] forKey:@"start"];
    [mirrorDict setValue:@[@"Data", @"数据"] forKey:@"data"];
    // time tracker cell
    [mirrorDict setValue:@[@"Tap to start", @"轻点开始计时"] forKey:@"tap_to_start"];
    // nickname
    [mirrorDict setValue:@[@"nickname", @"我的昵称"] forKey:@"nickname"];
    // Profile cell - theme
    [mirrorDict setValue:@[@"Apply darkmode", @"启用深色模式"] forKey:@"apply_darkmode"];
    // Profile cell - language
    [mirrorDict setValue:@[@"Apply Chinese", @"使用中文"] forKey:@"apply_chinese"];
    // Profile edit cell - hint
    [mirrorDict setValue:@[@"Click task name to edit (Your data won't be affected)", @"点击任务名称进行编辑（任务数据并不会受到影响）"] forKey:@"edit_taskname_hint"];
    // Profile edit cell
    [mirrorDict setValue:@[@"Untitled", @"未命名"] forKey:@"untitled"];
    [mirrorDict setValue:@[@"Delete", @"删除"] forKey:@"delete"];
    [mirrorDict setValue:@[@"Archive", @"归档"] forKey:@"archive"];
    // Profile add cell
    [mirrorDict setValue:@[@"Enter task title", @"输入任务名称"] forKey:@"enter_task_title"];
    [mirrorDict setValue:@[@"Create", @"创建"] forKey:@"create"];
    [mirrorDict setValue:@[@"Discard", @"放弃"] forKey:@"discard"];
    [mirrorDict setValue:@[@"Enter a title to create a new task", @"输入名称以创建新的任务"] forKey:@"add_taskname_hint"];
    [mirrorDict setValue:@[@"yesterday", @"昨天"] forKey:@"yesterday"];
    
    NSInteger index = [[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredChinese"] ? 1 : 0;
    return [mirrorDict valueForKey:key][index];
}



@end
