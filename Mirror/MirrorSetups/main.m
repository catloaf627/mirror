//
//  main.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/24.
//

// 上架App store流程链接
// https://www.appcoda.com.tw/ios-app-submission/
// https://blog.51cto.com/u_15848821/5823950

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
