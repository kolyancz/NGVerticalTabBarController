//
//  NGVerticalTabBarControllerDelegate.h
//  NGVerticalTabBarController
//
//  Created by Tretter Matthias on 14.02.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

@class NGVerticalTabBarController;
@class NGVerticalTabBarCell;

@protocol NGVerticalTabBarControllerDelegate <NSObject>

@required

/** Asks the delegate to customized the cell of the tabBar */
- (NGVerticalTabBarCell *)verticalTabBarController:(NGVerticalTabBarController *)tabBarController
                                    customizedCell:(NGVerticalTabBarCell *)cell
                                 forViewController:(UIViewController *)viewController
                                           atIndex:(NSUInteger)index;

@optional

/** Asks the delegate for the width of the UITableView that acts as the tabBar */
- (CGFloat)widthOfTabBarOfVerticalTabBarController:(NGVerticalTabBarController *)tabBarController;

/** Asks the delegate whether the specified view controller should be made active. */
- (BOOL)verticalTabBarController:(NGVerticalTabBarController *)tabBarController 
      shouldSelectViewController:(UIViewController *)viewController
                         atIndex:(NSUInteger)index;

/** Tells the delegate that the user selected an item in the tab bar. */
- (void)verticalTabBarController:(NGVerticalTabBarController *)tabBarController 
         didSelectViewController:(UIViewController *)viewController
                         atIndex:(NSUInteger)index;

@end
