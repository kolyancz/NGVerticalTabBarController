#import "NGVerticalTabBarCell.h"
#import "NGVerticalTabBar.h"

@implementation NGVerticalTabBarCell

+ (id)cellForTabBar:(NGVerticalTabBar *)tabBar {
    NSString *reuseIdentifier = NSStringFromClass([self class]);
    NGVerticalTabBarCell *cell = [tabBar dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (cell == nil) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    return cell; 
}

@end
