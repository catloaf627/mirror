//
//  MirrorLanguage.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/27.
//

#import "MirrorLanguage.h"

static MirrorLanguageType _languageType = MirrorLanguageTypeEnglish;

@implementation MirrorLanguage

+ (void)switchLanguage
{
    if (_languageType == MirrorLanguageTypeEnglish) {
        _languageType = MirrorLanguageTypeChinese;
    } else {
        _languageType = MirrorLanguageTypeEnglish;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MirrorSwitchLanguageNotification" object:nil];
}

+ (BOOL)isChinese
{
    return _languageType == MirrorLanguageTypeChinese;
}

+ (NSString *)mirror_stringWithKey:(NSString *)key
{
    NSMutableDictionary *mirrorDict = [NSMutableDictionary new];
    // tabs
    [mirrorDict setValue:@[@"Me", @"我的"] forKey:@"me"];
    [mirrorDict setValue:@[@"Start", @"冲鸭"] forKey:@"start"];
    [mirrorDict setValue:@[@"Data", @"数据"] forKey:@"data"];
    // time tracker cell
    [mirrorDict setValue:@[@"Double click to start", @"双击开始计时"] forKey:@"double_click_to_start"];
    // nickname
    [mirrorDict setValue:@[@"nickname", @"你的昵称"] forKey:@"nickname"];
    // Profile cell - theme
    [mirrorDict setValue:@[@"Apply darkmode", @"启用深色模式"] forKey:@"apply_darkmode"];
    // Profile cell - language
    [mirrorDict setValue:@[@"Apply Chinese", @"使用中文"] forKey:@"apply_chinese"];
    // Profile edit cell - hint
    [mirrorDict setValue:@[@"Click task name to edit (Your data won't be affected)", @"点击任务名称进行编辑（任务数据并不会受到影响）"] forKey:@"edit_taskname_hint"];
    // Profile edit cell - default title
    [mirrorDict setValue:@[@"Untitled", @"未命名"] forKey:@"untitled"];
    // Profile add cell
    [mirrorDict setValue:@[@"Enter task title", @"输入任务名称"] forKey:@"enter_task_title"];
    [mirrorDict setValue:@[@"Create", @"创建"] forKey:@"create"];
    [mirrorDict setValue:@[@"Discard", @"放弃"] forKey:@"discard"];
    [mirrorDict setValue:@[@"Enter a title to create a new task", @"输入名称以创建新的任务"] forKey:@"add_taskname_hint"];
    
    
    return [mirrorDict valueForKey:key][_languageType];
}



@end
