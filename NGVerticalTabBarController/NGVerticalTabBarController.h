//
//  NGVerticalTabBarController.h
//  NGVerticalTabBarController
//
//  Created by Tretter Matthias on 14.02.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "NGVerticalTabBarControllerDelegate.h"
#import "NGVerticalTabBar.h"
#import "NGVerticalTabBarCell.h"
#import "NGVerticalTabBarControllerAnimation.h"


/** NGVerticalTabBarController is a vertical TabBar displayed on the left side of the device */
@interface NGVerticalTabBarController : UIViewController

/** An array of the view controllers displayed by the tab bar */
@property (nonatomic, copy) NSArray *viewControllers;
/** The index of the view controller associated with the currently selected tab item. */
@property (nonatomic, assign) NSUInteger selectedIndex;
/** The view controller associated with the currently selected tab item. */
@property (nonatomic, unsafe_unretained) UIViewController *selectedViewController;

/** The tab bar controller’s delegate object. */
@property (nonatomic, unsafe_unretained) id<NGVerticalTabBarControllerDelegate> delegate;

/** The tableView used to display all tab bar elements */
@property (nonatomic, strong, readonly) NGVerticalTabBar *tabBar;
/** The class of the tableViewCell of the tabBar, defaults to NGVerticalTabBarCell */
@property (nonatomic, assign) Class tabBarCellClass;

/** The animation used when changing selected tabBarItem, default: none */
@property (nonatomic, assign) NGVerticalTabBarControllerAnimation animation;
/** The duration of the used animation, only taken into account when animation is different from none */
@property (nonatomic, assign) NSTimeInterval animationDuration;

@property (nonatomic, readonly) BOOL isAnimating;

/** Sets the view controllers of the tab bar controller. */
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

/** The designated initializer. */
- (id)initWithDelegate:(id<NGVerticalTabBarControllerDelegate>)delegate;

@end
