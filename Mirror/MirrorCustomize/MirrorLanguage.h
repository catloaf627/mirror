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

+(NSString *)stringWithKey:(NSString *)key Language:(MirrorLanguageType)language;

@end

NS_ASSUME_NONNULL_END
