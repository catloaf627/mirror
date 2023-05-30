//
//  HeartFooter.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/3.
//

#import "HeartFooter.h"
#import <Masonry/Masonry.h>
#import "SplitLineView.h"
#import "MirrorMacro.h"
#import "UIColor+MirrorColor.h"

@interface HeartFooter ()

@property (nonatomic, strong) SplitLineView *splitView;

@end

@implementation HeartFooter

- (void)config
{
    [self addSubview:self.splitView];
    [self.splitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(20);
        make.centerX.offset(0);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(10);
    }];
    
}

- (SplitLineView *)splitView
{
    if (!_splitView) {
        _splitView = [[SplitLineView alloc] initWithImage:@"heart.fill" color:[UIColor mirrorColorNamed:MirrorColorTypeTextHint]];
    }
    return _splitView;
}

@end
