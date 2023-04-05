//
//  NSMutableDictionary+MirrorDictionary.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/10/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (MirrorDictionary)

- (id)valueForKey:(NSString *)key defaultObject:(id)defObj;

@end

NS_ASSUME_NONNULL_END
