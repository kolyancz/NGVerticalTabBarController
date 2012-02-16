//
//  NGColoredViewController.m
//  NGVerticalTabBarControllerDemo
//
//  Created by Tretter Matthias on 16.02.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "NGColoredViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation NGColoredViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *randomColor = [UIColor colorWithRed:arc4random()%256/255. green:arc4random()%256/255. blue:arc4random()%256/255. alpha:1.f];
    
    self.view.backgroundColor = randomColor;
    self.view.layer.borderColor = [UIColor orangeColor].CGColor;
    self.view.layer.borderWidth = 2.f;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end
