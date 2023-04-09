//
//  MUXToast.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIColor+MirrorColor.h"
#import "MirrorStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUXToast : NSObject

+ (void)taskSaved:(NSString *)taskName onVC:(UIViewController *)vc type:(TaskSavedType)savedType;
@end

NS_ASSUME_NONNULL_END
