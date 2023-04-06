//
//  MirrorHistogram.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import "MirrorHistogram.h"

// 在外展示的柱状图可用（type为用户自定的type，默认是0）；entrance点进去后展示的柱状图也可用，type为对应entrance的type
@implementation MirrorHistogram

- (instancetype)initWithType:(MirrorHistogramType)type
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.layer.cornerRadius = 14;
        // type
    }
    return self;
}

@end
