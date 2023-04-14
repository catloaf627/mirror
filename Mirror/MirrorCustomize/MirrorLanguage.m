//
//  MirrorLanguage.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/27.
//

#import "MirrorLanguage.h"
#import "MirrorSettings.h"

@implementation MirrorLanguage

+ (NSString *)mirror_stringWithKey:(NSString *)key
{
    NSMutableDictionary *mirrorDict = [NSMutableDictionary new];
    // general
    [mirrorDict setValue:@[@"Something went wrong", @"出错了"] forKey:@"something_went_wrong"];
    
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
    // Profile cell - immersive mode
    [mirrorDict setValue:@[@"Apply immersive mode", @"启用沉浸模式"] forKey:@"apply_immersive_mode"];
    // Profile cell - week starts on Monday
    [mirrorDict setValue:@[@"Week starts on Monday", @"将周一作为一周的第一天"] forKey:@"week_starts_on_Monday"];
    // Profile edit cell - hint
    [mirrorDict setValue:@[@"Click task name to edit (Your data won't be affected)", @"点击任务名称进行编辑（任务数据并不会受到影响）"] forKey:@"edit_taskname_hint"];
    // Profile edit cell
    [mirrorDict setValue:@[@"Delete this task?", @"删除此任务？"] forKey:@"delete_task_?"];
    [mirrorDict setValue:@[@"You can also archive this task", @"你也可以选择归档此任务"] forKey:@"you_can_also_archive_this_task"];
    [mirrorDict setValue:@[@"Save", @"保存"] forKey:@"save"];
    [mirrorDict setValue:@[@"Delete", @"删除"] forKey:@"delete"];
    [mirrorDict setValue:@[@"Archive", @"归档"] forKey:@"archive"];
    [mirrorDict setValue:@[@"Cancel", @"取消"] forKey:@"cancel"];
    // Profile add cell
    [mirrorDict setValue:@[@"Enter task title", @"输入任务名称"] forKey:@"enter_task_title"];
    [mirrorDict setValue:@[@"Create", @"创建"] forKey:@"create"];
    [mirrorDict setValue:@[@"Discard", @"放弃"] forKey:@"discard"];
    [mirrorDict setValue:@[@"Enter a title to create a new task", @"输入名称以创建新的任务"] forKey:@"add_taskname_hint"];
    [mirrorDict setValue:@[@"Name field cannot be empty", @"任务名不能为空"] forKey:@"name_field_cannot_be_empty"];
    [mirrorDict setValue:@[@"Gotcha", @"知道啦"] forKey:@"gotcha"];
    [mirrorDict setValue:@[@"Task cannot be duplicated", @"任务不可重复"] forKey:@"task_cannot_be_duplicated"];
    [mirrorDict setValue:@[@"This task exists in current task list", @"这个任务已经存在于当前任务列表中"] forKey:@"this_task_exists_in_current_task_list"];
    [mirrorDict setValue:@[@"This task exists in the archived task list. You can activate it in [Data]", @"这个任务已经存在于归档任务列表中。你可以在【数据】中重新激活此任务。"] forKey:@"this_task_exists_in_the_archived_task_list"];
    // Data entrance cell
    [mirrorDict setValue:@[@"Today", @"今日数据"] forKey:@"today"];
    [mirrorDict setValue:@[@"This week", @"本周数据"] forKey:@"this_week"];
    [mirrorDict setValue:@[@"This month", @"本月数据"] forKey:@"this_month"];
    [mirrorDict setValue:@[@"This year", @"今年数据"] forKey:@"this_year"];
    
    // 全屏
    [mirrorDict setValue:@[@"yesterday", @"昨天"] forKey:@"yesterday"];
    [mirrorDict setValue:@[@"Go!", @"开始!"] forKey:@"go"];
    
    // 闪烁
    [mirrorDict setValue:@[@"Counting...", @"计时中..."] forKey:@"counting"];
    
    // Histogram
    [mirrorDict setValue:@[@"No tasks today", @"今天还没有任务"] forKey:@"no_tasks_today"];
    [mirrorDict setValue:@[@"No tasks this week", @"本周还没有任务"] forKey:@"no_tasks_this_week"];
    [mirrorDict setValue:@[@"No tasks this month", @"本月还没有任务"] forKey:@"no_tasks_this_month"];
    [mirrorDict setValue:@[@"No tasks this year", @"今年还没有任务"] forKey:@"no_tasks_this_year"];
    
    NSInteger index = [MirrorSettings appliedChinese] ? 1 : 0;
    return [mirrorDict valueForKey:key][index];
}


+ (NSString *)mirror_stringWithKey:(NSString *)key
                  with1Placeholder:(NSString *)placeholder
{
    NSMutableDictionary *mirrorDict = [NSMutableDictionary new];
    [mirrorDict setValue:@[@"[%@] has been lasted more than 24 hours. It was stopped and saved automatically.", @"【%@】时长超过24小时，已自动停止并保存"] forKey:@"reached_limited_time"];
    [mirrorDict setValue:@[@"[%@] not saved", @"【%@】未保存"] forKey:@"too_short_to_save"];
    
    
    NSInteger index = [MirrorSettings appliedChinese] ? 1 : 0;
    return [NSString stringWithFormat:[mirrorDict valueForKey:key][index], placeholder];
}

+ (NSString *)mirror_stringWithKey:(NSString *)key
                  with1Placeholder:(NSString *)placeholder1
                  with2Placeholder:(NSString *)placeholder2
{
    NSMutableDictionary *mirrorDict = [NSMutableDictionary new];
    [mirrorDict setValue:@[@"[%@] has been done!\nlasted: %@", @"【%@】已完成！\n持续时间：%@"] forKey:@"task_has_been_done"];
    
    
    NSInteger index = [MirrorSettings appliedChinese] ? 1 : 0;
    return [NSString stringWithFormat:[mirrorDict valueForKey:key][index], placeholder1, placeholder2];
}



@end
