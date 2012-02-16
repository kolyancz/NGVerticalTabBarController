//
//  NGVerticalTabBarControllerAnimation.h
//  NGVerticalTabBarController
//
//  Created by Tretter Matthias on 16.02.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

/**
 The animation used when we change the selected tabItem, default is none. Animations are only supported on iOS 5.
 */
typedef enum {
    NGVerticalTabBarControllerAnimationNone,
    NGVerticalTabBarControllerAnimationFade,
    NGVerticalTabBarControllerAnimationCurl,
    NGVerticalTabBarControllerAnimationMove
} NGVerticalTabBarControllerAnimation;