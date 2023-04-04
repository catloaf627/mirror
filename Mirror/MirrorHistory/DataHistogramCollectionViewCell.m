//
//  DataHistogramCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/4.
//

#import "DataHistogramCollectionViewCell.h"

@implementation DataHistogramCollectionViewCell

+ (NSString *)identifier;
{
    return NSStringFromClass(self.class);
}

- (void)configCell
{
    self.contentView.backgroundColor = [UIColor systemPinkColor];
}

@end
