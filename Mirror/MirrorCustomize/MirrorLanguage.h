//
//  MirrorLanguage.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MirrorLanguage : NSObject

+(NSString *)mirror_stringWithKey:(NSString *)key; // 无参数
+ (NSString *)mirror_stringWithKey:(NSString *)key
                  with1Placeholder:(NSString *)placeholder; // 1参数
+ (NSString *)mirror_stringWithKey:(NSString *)key // 2参数
                  with1Placeholder:(NSString *)placeholder1
                  with2Placeholder:(NSString *)placeholder2;

@end

NS_ASSUME_NONNULL_END
