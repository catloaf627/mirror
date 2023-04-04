//
//  HistogramView.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/4.
//

#import "HistogramView.h"
#import "UIColor+MirrorColor.h"

@implementation HistogramView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeAddTaskCellBG];
        self.layer.cornerRadius = 14;
    }
    return self;
}

- (void)reloadHistogramView
{
    
}

@end
