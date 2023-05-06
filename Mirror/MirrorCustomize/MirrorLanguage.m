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
    [mirrorDict setValue:@[@"Start", @"计时"] forKey:@"start"];
    [mirrorDict setValue:@[@"Today", @"今天"] forKey:@"today"];
    [mirrorDict setValue:@[@"Data", @"数据"] forKey:@"data"];
    [mirrorDict setValue:@[@"Record", @"记录"] forKey:@"record"];
    // nickname
    [mirrorDict setValue:@[@"nickname", @"我的昵称"] forKey:@"nickname"];
    // Settings
    [mirrorDict setValue:@[@"Apply darkmode", @"启用深色模式"] forKey:@"apply_darkmode"];
    [mirrorDict setValue:@[@"Apply Chinese", @"使用中文"] forKey:@"apply_chinese"];
    [mirrorDict setValue:@[@"Week starts on Monday", @"将周一作为一周的第一天"] forKey:@"week_starts_on_Monday"];
    [mirrorDict setValue:@[@"Show record index", @"展示记录的序号"] forKey:@"show_record_index"];
    // Profile edit cell - hint
    [mirrorDict setValue:@[@"Click task name to edit (Your data won't be affected)", @"点击任务名称进行编辑（任务数据并不会受到影响）"] forKey:@"edit_taskname_hint"];
    // Profile edit cell
    [mirrorDict setValue:@[@"Delete or archive this task", @"删除或归档此任务"] forKey:@"delete_or_archive"];
    [mirrorDict setValue:@[@"Save", @"保存"] forKey:@"save"];
    [mirrorDict setValue:@[@"Remove", @"移掉"] forKey:@"remove"];
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
    
    // 全屏
    [mirrorDict setValue:@[@"Go!", @"开始!"] forKey:@"go"];
    [mirrorDict setValue:@[@"Give up", @"放弃"] forKey:@"give_up"];
    [mirrorDict setValue:@[@"Stop", @"结束"] forKey:@"stop"];
    
    // Task record
    [mirrorDict setValue:@[@"Counting...", @"计时中..."] forKey:@"counting"];
    [mirrorDict setValue:@[@"Lasted: ", @"持续时间："] forKey:@"lasted"];
    [mirrorDict setValue:@[@" (Archived) ", @"（已归档）"] forKey:@"archived_tag"];
    
    // Delete period
    [mirrorDict setValue:@[@"Delete this time period? ", @"确定删除这个时间段？"] forKey:@"delete_period_?"];
    
    // All tasks
    [mirrorDict setValue:@[@"Delete this task? ", @"确定删除这个任务？"] forKey:@"delete_task_?"];
    [mirrorDict setValue:@[@"Created at " , @"创建于 "] forKey:@"created_at"];
    [mirrorDict setValue:@[@"Edit tasks" , @"编辑任务"] forKey:@"edit_tasks"];
    [mirrorDict setValue:@[@"Check all >" , @"查看所有>"] forKey:@"check_all"];
    
    // History type switch
    [mirrorDict setValue:@[@"Day", @"日"] forKey:@"segment_day"];
    [mirrorDict setValue:@[@"Week", @"周"] forKey:@"segment_week"];
    [mirrorDict setValue:@[@"Month", @"月"] forKey:@"segment_month"];
    [mirrorDict setValue:@[@"Year", @"年"] forKey:@"segment_year"];
    
    // 星期
    [mirrorDict setValue:@[@"Sun", @"周日"] forKey:@"sunday"];
    [mirrorDict setValue:@[@"Mon", @"周一"] forKey:@"monday"];
    [mirrorDict setValue:@[@"Tue", @"周二"] forKey:@"tuesday"];
    [mirrorDict setValue:@[@"Wed", @"周三"] forKey:@"wednesday"];
    [mirrorDict setValue:@[@"Thu", @"周四"] forKey:@"thursday"];
    [mirrorDict setValue:@[@"Fri", @"周五"] forKey:@"friday"];
    [mirrorDict setValue:@[@"Sat", @"周六"] forKey:@"saturday"];
    
    // 月份
    [mirrorDict setValue:@[@"Jan", @"1月"] forKey:@"january"];
    [mirrorDict setValue:@[@"Feb", @"2月"] forKey:@"february"];
    [mirrorDict setValue:@[@"Mar", @"3月"] forKey:@"march"];
    [mirrorDict setValue:@[@"Apr", @"4月"] forKey:@"april"];
    [mirrorDict setValue:@[@"May", @"5月"] forKey:@"may"];
    [mirrorDict setValue:@[@"Jun", @"6月"] forKey:@"june"];
    [mirrorDict setValue:@[@"Jul", @"7月"] forKey:@"july"];
    [mirrorDict setValue:@[@"Aug", @"8月"] forKey:@"august"];
    [mirrorDict setValue:@[@"Sep", @"9月"] forKey:@"september"];
    [mirrorDict setValue:@[@"Oct", @"10月"] forKey:@"october"];
    [mirrorDict setValue:@[@"Nov", @"11月"] forKey:@"november"];
    [mirrorDict setValue:@[@"Dec", @"12月"] forKey:@"december"];
    
    
    
    // Span histogram empty hint
    [mirrorDict setValue:@[@"No data", @"暂无数据"] forKey:@"no_data"];
    // Today empty hint
    [mirrorDict setValue:@[@"No tasks today", @"今天暂无任务"] forKey:@"no_data_today"];
    
    // today total
    [mirrorDict setValue:@[@"Total: ", @"总时长："] forKey:@"total"];
    
    // Time editing (这个页面需要的save，上面已经有了)
    [mirrorDict setValue:@[@"Starts at", @"开始时间"] forKey:@"starts_at"];
    [mirrorDict setValue:@[@"OR", @"或者"] forKey:@"or"];
    [mirrorDict setValue:@[@"Start now", @"开始计时"] forKey:@"start_now"];
    [mirrorDict setValue:@[@" hours", @" 小时"] forKey:@"picker_hours"];
    [mirrorDict setValue:@[@" mins", @" 分钟"] forKey:@"picker_mins"];
    [mirrorDict setValue:@[@" hour", @" 小时"] forKey:@"picker_hour"];
    [mirrorDict setValue:@[@" min", @" 分钟"] forKey:@"picker_min"];
    
    // Grid VC
    [mirrorDict setValue:@[@"Activities", @"活动记录"] forKey:@"activities"];
    
    // All records
    [mirrorDict setValue:@[@"All records", @"所有记录"] forKey:@"all_records"];
    
    NSInteger index = [MirrorSettings appliedChinese] ? 1 : 0;
    return [mirrorDict valueForKey:key][index];
}


+ (NSString *)mirror_stringWithKey:(NSString *)key
                  with1Placeholder:(NSString *)placeholder
{
    NSMutableDictionary *mirrorDict = [NSMutableDictionary new];
    
    // MUXToast
    [mirrorDict setValue:@[@"[%@] not saved", @"【%@】未保存"] forKey:@"too_short_to_save"];
    
    // Edit period
    [mirrorDict setValue:@[@"The start time of No.%@ task: No later than the end time of this task, nor earlier than the end time of the previous task", @"第%@次任务的开始时间：不得晚于本次任务的结束时间，不得早于上一个任务的结束时间"] forKey:@"start_time_for_period"];
    [mirrorDict setValue:@[@"The end time of No.%@ task: No earlier than the start time of this task, nor later than the start time of the next task", @"第%@次任务的结束时间：不得早于本次任务的开始时间，不得晚于下一个任务的开始时间"] forKey:@"end_time_for_period"];
    
    // 时间
    [mirrorDict setValue:@[@"%@h ", @"%@时"] forKey:@"h"];
    [mirrorDict setValue:@[@"%@m ", @"%@分"] forKey:@"m"];
    [mirrorDict setValue:@[@"%@s", @"%@秒"] forKey:@"s"];
    
    [mirrorDict setValue:@[@"%@ hour ", @"%@小时"] forKey:@"hour"];
    [mirrorDict setValue:@[@"%@ min ", @"%@分钟"] forKey:@"min"];
    [mirrorDict setValue:@[@"%@ second", @"%@秒"] forKey:@"second"];
    
    [mirrorDict setValue:@[@"%@ hours ", @"%@小时"] forKey:@"hours"];
    [mirrorDict setValue:@[@"%@ mins ", @"%@分钟"] forKey:@"mins"];
    [mirrorDict setValue:@[@"%@ seconds", @"%@秒"] forKey:@"seconds"];
    
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
