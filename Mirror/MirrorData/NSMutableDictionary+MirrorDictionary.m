//
//  NSMutableDictionary+MirrorDictionary.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/10/24.
//

#import "NSMutableDictionary+MirrorDictionary.h"

@implementation NSMutableDictionary (MirrorDictionary)

- (id)valueForKey:(NSString *)key defaultObject:(id)defObj
{
    id value = [self objectForKey:key];
    if (!value) {
        return defObj;
    } else {
        return value;
    }
}

@end
