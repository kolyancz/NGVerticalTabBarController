//
//  NGColoredViewController.m
//  NGVerticalTabBarControllerDemo
//
//  Created by Tretter Matthias on 16.02.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "NGColoredViewController.h"
#import <QuartzCore/QuartzCore.h>

#define NGLogFunction() NSLog(@"Method called: %s", __FUNCTION__)

@implementation NGColoredViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *randomColor = [UIColor colorWithRed:arc4random()%256/255. green:arc4random()%256/255. blue:arc4random()%256/255. alpha:1.f];
    
    self.view.backgroundColor = randomColor;
    self.view.layer.borderColor = [UIColor orangeColor].CGColor;
    self.view.layer.borderWidth = 2.f;
    
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    blackView.backgroundColor = [UIColor blackColor];
    blackView.center = self.view.center;
    blackView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
                               | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:blackView];
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 120, 20, 100, 100)];
    whiteView.backgroundColor = [UIColor whiteColor];
    whiteView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:whiteView];
    
    NGLogFunction();
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    NGLogFunction();
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 
    NGLogFunction();
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NGLogFunction();
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
    NGLogFunction();
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
    
    NGLogFunction();
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    NGLogFunction();
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    NGLogFunction();
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    NGLogFunction();
}

@end
