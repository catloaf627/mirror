//
//  SplitLineView.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/3.
//

#import "SplitLineView.h"
#import <Masonry/Masonry.h>
#import "MirrorMacro.h"

static CGFloat const kIconWidth = 10;
static CGFloat const kIconPadding = 3;
static CGFloat const kLeftRightPadding = 20;
static CGFloat const kLineHeight = 1;

@interface SplitLineView ()

@property (nonatomic, strong) UIView *leftLine;
@property (nonatomic, strong) UIImageView *heartView ;
@property (nonatomic, strong) UIView *rightLine;

@end

@implementation SplitLineView

- (instancetype)initWithColor:(UIColor *)color
{
    self = [super init];
    if (self) {
    
        [self addSubview:self.leftLine];
        self.leftLine.backgroundColor = color;
        [self.leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(kLeftRightPadding);
            make.centerY.offset(0);
            make.width.mas_equalTo((kScreenWidth - 2*kLeftRightPadding - 2*kIconPadding - kIconWidth)/2);
            make.height.mas_equalTo(kLineHeight);
        }];
        
        [self addSubview:self.heartView];
        [self.heartView setTintColor:color];
        [self.heartView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.offset(0);
            make.width.height.mas_equalTo(kIconWidth);
        }];
        
        [self addSubview:self.rightLine];
        self.rightLine.backgroundColor = color;
        [self.rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.offset(-kLeftRightPadding);
            make.centerY.offset(0);
            make.width.mas_equalTo((kScreenWidth - 2*kLeftRightPadding - 2*kIconPadding - kIconWidth)/2);
            make.height.mas_equalTo(kLineHeight);
        }];
        
    }
    return self;
}

- (UIView *)leftLine
{
    if (!_leftLine) {
        _leftLine = [UIView new];
    }
    return _leftLine;
}

- (UIImageView *)heartView
{
    if (!_heartView) {
        _heartView = [UIImageView new];
        UIImage *image = [[UIImage systemImageNamed:@"heart.fill"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _heartView.image = image;
    }
    return _heartView;
}

- (UIView *)rightLine
{
    if (!_rightLine) {
        _rightLine = [UIView new];
    }
    return _rightLine;
}

@end
