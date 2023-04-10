//
//  MirrorSettings.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/10.
//

#import "MirrorSettings.h"

@implementation MirrorSettings

+ (BOOL)appliedImmersiveMode
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"MirrorUserPreferredImmersiveMode"];
}

@end
