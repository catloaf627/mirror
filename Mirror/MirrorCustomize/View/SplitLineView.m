//
//  SplitLineView.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/3.
//

#import "SplitLineView.h"
#import <Masonry/Masonry.h>
#import "MirrorMacro.h"
#import "UIColor+MirrorColor.h"

static CGFloat const kIconWidth = 10;
static CGFloat const kCenterPadding = 3;
static CGFloat const kLeftRightPadding = 50;
static CGFloat const kLineHeight = 1;

@interface SplitLineView ()

@property (nonatomic, strong) UIView *leftLine;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIView *rightLine;

@end

@implementation SplitLineView

- (instancetype)initWithImage:(NSString *)imageName color:(UIColor *)color
{
    self = [super init];
    if (self) {
        [self addSubview:self.imageView];
        UIImage *image = [[UIImage systemImageNamed:imageName]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.imageView.image = image;
        [self.imageView setTintColor:color];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.offset(0);
            make.width.height.mas_equalTo(kIconWidth);
        }];
        
        [self addSubview:self.leftLine];
        self.leftLine.backgroundColor = color;
        [self.leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(kLeftRightPadding);
            make.right.mas_equalTo(self.imageView.mas_left).offset(-kCenterPadding);
            make.centerY.offset(0);
            make.height.mas_equalTo(kLineHeight);
        }];
        
        [self addSubview:self.rightLine];
        self.rightLine.backgroundColor = color;
        [self.rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.offset(-kLeftRightPadding);
            make.left.mas_equalTo(self.imageView.mas_right).offset(kCenterPadding);
            make.centerY.offset(0);
            make.width.mas_equalTo((kScreenWidth - 2*kLeftRightPadding - 2*kCenterPadding - kIconWidth)/2);
            make.height.mas_equalTo(kLineHeight);
        }];
        
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text color:(UIColor *)color
{
    self = [super init];
    if (self) {
        [self addSubview:self.textLabel];
        self.textLabel.textColor = color;
        self.textLabel.text =  text;
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.offset(0);
            make.width.height.mas_equalTo([self textWidth:text]);
        }];
        
        [self addSubview:self.leftLine];
        self.leftLine.backgroundColor = color;
        [self.leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(kLeftRightPadding);
            make.right.mas_equalTo(self.textLabel.mas_left).offset(-kCenterPadding);
            make.centerY.offset(0);
            make.height.mas_equalTo(kLineHeight);
        }];
        
        [self addSubview:self.rightLine];
        self.rightLine.backgroundColor = color;
        [self.rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.offset(-kLeftRightPadding);
            make.left.mas_equalTo(self.textLabel.mas_right).offset(kCenterPadding);
            make.centerY.offset(0);
            make.height.mas_equalTo(kLineHeight);
        }];
    }
    return self;
}

- (void)updateText:(NSString *)text
{
    self.textLabel.text = text;
    [self.textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo([self textWidth:text]);
    }];
}

#pragma mark - Getters

- (UIView *)leftLine
{
    if (!_leftLine) {
        _leftLine = [UIView new];
    }
    return _leftLine;
}

- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [UILabel new];
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:14];
    }
    return _textLabel;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [UIImageView new];
    }
    return _imageView;
}

- (UIView *)rightLine
{
    if (!_rightLine) {
        _rightLine = [UIView new];
    }
    return _rightLine;
}

- (CGFloat)textWidth:(NSString *)text
{
    CGFloat height  = 15;
    NSDictionary *textAttrs = @{NSFontAttributeName : [UIFont fontWithName:@"TrebuchetMS-Italic" size:14]};
    CGFloat width = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:textAttrs context:nil].size.width;
    return width;
}

@end
