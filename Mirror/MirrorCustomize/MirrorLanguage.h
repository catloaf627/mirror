//
//  MirrorLanguage.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MirrorLanguageType) {
    MirrorLanguageTypeEnglish,
    MirrorLanguageTypeChinese,
};


@interface MirrorLanguage : NSObject

+ (void)switchLanguage;
+ (BOOL)isChinese;
+(NSString *)mirror_stringWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
