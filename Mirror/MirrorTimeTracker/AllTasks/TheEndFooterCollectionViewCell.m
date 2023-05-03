//
//  TheEndFooterCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/3.
//

#import "TheEndFooterCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import "SplitLineView.h"
#import "MirrorMacro.h"

@interface TheEndFooterCollectionViewCell ()

@property (nonatomic, strong) SplitLineView *splitView;

@end

@implementation TheEndFooterCollectionViewCell

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
        _splitView = [[SplitLineView alloc] initWithText:@"The end"];
    }
    return _splitView;
}

@end
