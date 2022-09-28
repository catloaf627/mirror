//
//  MirrorLanguage.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/27.
//

#import "MirrorLanguage.h"

@implementation MirrorLanguage

+(NSString *)stringWithKey:(NSString *)key Language:(MirrorLanguageType)language
{
    NSMutableDictionary *mirrorDict = [NSMutableDictionary new];
    // tabs
    [mirrorDict setValue:@[@"Me", @"我的"] forKey:@"me"];
    [mirrorDict setValue:@[@"Start", @"冲鸭"] forKey:@"start"];
    [mirrorDict setValue:@[@"Data", @"数据"] forKey:@"data"];
    //time tracker cell
    [mirrorDict setValue:@[@"Tap to start", @"点击开始"] forKey:@"tap_to_start"];
    
    return [mirrorDict valueForKey:key][language];
}



@end
