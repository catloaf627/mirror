//
//  SettingsViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/18.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    UIButton *button = [UIButton new];
//    button.backgroundColor = [UIColor blackColor];
//    button.frame = CGRectMake(0, 0, 200, 200);
//    [button addTarget:self action:@selector(aaa) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIView *view = [UIButton new];
    view.backgroundColor = [UIColor blackColor];
    view.frame = CGRectMake(0, 0, 200, 200);
    
    [self.view addSubview:view];
    
    

    UITapGestureRecognizer *singleFingerTap =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];

    //The event handling method

}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
  CGPoint location = [recognizer locationInView:[recognizer.view superview]];

  //Do stuff here...
}


@end
