//
//  HistogramView.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/4.
//

#import "HistogramView.h"

@implementation HistogramView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor systemPinkColor];
        self.layer.cornerRadius = 14;
    }
    return self;
}

- (void)reloadHistogramView
{
    
}

@end
