//
//  MirrorPiechart.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/9.
//

#import <UIKit/UIKit.h>
#import "MirrorDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PiechartDelegate <NSObject>  // 让对应的legend高亮

- (void)highlightTaskname:(NSString *)taskname;
- (void)cancelHighlightTaskname:(NSString *)taskname;

@end

@interface MirrorPiechart : UIView

@property (nonatomic, weak) UIView<PiechartDelegate> *delegate;

- (instancetype)initWithData:(NSMutableArray<MirrorDataModel *> *)data width:(CGFloat)width enableInteractive:(BOOL)enableInteractive;
- (void)updateWithData:(NSMutableArray<MirrorDataModel *> *)data width:(CGFloat)width enableInteractive:(BOOL)enableInteractive;

@end

NS_ASSUME_NONNULL_END
