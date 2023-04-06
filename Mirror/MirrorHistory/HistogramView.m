//
//  HistogramView.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/4.
//

#import "HistogramView.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "UIColor+MirrorColor.h"
#import "MirrorHistogram.h"

@interface HistogramView ()

@property (nonatomic, strong) MirrorHistogram *barChart;

@end

@implementation HistogramView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
        self.layer.cornerRadius = 14;
        [self p_setupUI];
    }
    return self;
}

- (void)p_setupUI
{
    [self addSubview:self.barChart];
    [self.barChart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.offset(0);
    }];
}

- (void)reloadHistogramView
{
    
}

- (MirrorHistogram *)barChart
{
    if (!_barChart) {
        _barChart = [[MirrorHistogram alloc] initWithType:0]; // 默认展示today
    }
    return _barChart;
}


@end
