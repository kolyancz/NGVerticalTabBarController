//
//  AppDelegate.m
//  NGVerticalTabBarControllerDemo
//
//  Created by Tretter Matthias on 16.02.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "AppDelegate.h"
#import "NGColoredViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    NSArray *viewController = [NSArray arrayWithObjects:[[NGColoredViewController alloc] initWithNibName:nil bundle:nil],
                               [[NGColoredViewController alloc] initWithNibName:nil bundle:nil],
                               [[NGColoredViewController alloc] initWithNibName:nil bundle:nil],
                               [[NGColoredViewController alloc] initWithNibName:nil bundle:nil],
                               [[NGColoredViewController alloc] initWithNibName:nil bundle:nil],nil];
    
    NGVerticalTabBarController *tabBarController = [[NGVerticalTabBarController alloc] initWithDelegate:self];
    
    tabBarController.viewControllers = viewController;
    self.window.rootViewController = tabBarController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NGVerticalTabBarControllerDelegate
////////////////////////////////////////////////////////////////////////

- (NGVerticalTabBarCell *)verticalTabBarController:(NGVerticalTabBarController *)tabBarController
                                    customizedCell:(NGVerticalTabBarCell *)cell
                                 forViewController:(UIViewController *)viewController
                                           atIndex:(NSUInteger)index {
    cell.textLabel.text = [NSString stringWithFormat:@"%d", index];
    return cell;
}

@end
