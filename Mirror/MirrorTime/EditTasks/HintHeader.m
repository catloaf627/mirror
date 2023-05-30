//
//  HintHeader.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/30.
//

#import "HintHeader.h"
#import <Masonry/Masonry.h>
#import "UIColor+MirrorColor.h"
#import "MirrorLanguage.h"

@interface HintHeader ()

@property (nonatomic, strong) UILabel *hintLabel;

@end

@implementation HintHeader

- (void)config
{
    [self addSubview:self.hintLabel];
    NSArray *hints = @[[MirrorLanguage mirror_stringWithKey:@"hint0"], [MirrorLanguage mirror_stringWithKey:@"hint1"], [MirrorLanguage mirror_stringWithKey:@"hint2"]];
    NSString *hint = hints[arc4random() % hints.count]; // 随机选一个hint
    self.hintLabel.text = hint;
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.right.offset(-20);
        make.bottom.offset(-10); // 和下面的cell的距离 与 cell之间的距离保持一致
        make.height.mas_equalTo(20);
    }];
}


- (UILabel *)hintLabel
{
    if (!_hintLabel) {
        _hintLabel = [UILabel new];
        _hintLabel.adjustsFontSizeToFitWidth = YES;
        _hintLabel.textAlignment = NSTextAlignmentLeft;
        _hintLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _hintLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:12];
    }
    return _hintLabel;
}



@end
