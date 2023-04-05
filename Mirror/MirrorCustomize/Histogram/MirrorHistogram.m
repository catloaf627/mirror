//
//  MirrorHistogram.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import "MirrorHistogram.h"

@implementation MirrorHistogram

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor systemPinkColor];
        self.layer.cornerRadius = 14;
    }
    return self;
}

@end
