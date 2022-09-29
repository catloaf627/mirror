//
//  HistoryViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/25.
//

#import "HistoryViewController.h"
#import "UIColor+MirrorColor.h"
#import "MirrorTabsManager.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadVC) name:@"MirrorSwitchThemeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadVC) name:@"MirrorSwitchLanguageNotification" object:nil];
    }
    return self;
}

- (void)reloadVC
{
    // 更新tab item
    [MirrorTabsManager updateHistoryTabItemWithTabController:self.tabBarController];
    [self viewDidLoad];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
}

@end
