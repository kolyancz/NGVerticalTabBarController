#import "NGVerticalTabBarController.h"
#import "NGVerticalTabBarControllerDelegate.h"
#import "NGVerticalTabBar.h"
#import "NGVerticalTabBarCell.h"

// the default width of the tabBar
#define kNGTabBarControllerDefaultWidth     150.f


@interface NGVerticalTabBarController () <UITableViewDataSource, UITableViewDelegate> {
    // re-defined as mutable
    NSMutableArray *viewControllers_;
    
    // flags for methods implemented in the delegate
    struct {
        unsigned int widthOfTabBar:1;
		unsigned int shouldSelectViewController:1;
		unsigned int didSelectViewController:1;
	} delegateFlags_;
}

// re-defined as read/write
@property (nonatomic, strong, readwrite) NGVerticalTabBar *tabBar;

- (void)updateUI;

- (CGFloat)askDelegateForWidthOfTabBar;
- (NGVerticalTabBarCell *)askDelegateForCellOfViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
- (BOOL)askDelegateIfWeShouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
- (void)callDelegateDidSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;

@end

@implementation NGVerticalTabBarController

@synthesize viewControllers = viewControllers_;
@synthesize selectedIndex = selectedIndex_;
@synthesize delegate = delegate_;
@synthesize tabBar = tabBar_;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithViewControllers:(NSArray *)viewControllers {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        if (viewControllers.count > 0) {
            viewControllers_ = [NSMutableArray arrayWithArray:viewControllers];
            selectedIndex_ = 0;
        } else {
            viewControllers_ = [NSMutableArray array];
            selectedIndex_ = NSNotFound;
        }
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithViewControllers:nil];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat width = [self askDelegateForWidthOfTabBar];
    self.tabBar = [[NGVerticalTabBar alloc] initWithFrame:CGRectMake(0.f, 0.f, width, self.view.bounds.size.height) style:UITableViewStylePlain];
    
    self.tabBar.dataSource = self;
    self.tabBar.delegate = self;
}

- (void)viewDidUnload {
    self.tabBar.dataSource = nil;
    self.tabBar.delegate = nil;
    self.tabBar = nil;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tabBar reloadData];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NGVerticalTabBarController
////////////////////////////////////////////////////////////////////////

- (void)setDelegate:(id<NGVerticalTabBarControllerDelegate>)delegate {
    if (delegate != delegate_) {
        delegate_ = delegate;
        
        // update delegate flags
        delegateFlags_.widthOfTabBar = [delegate respondsToSelector:@selector(widthOfTabBarOfVerticalTabBarController:)];
        delegateFlags_.shouldSelectViewController = [delegate respondsToSelector:@selector(verticalTabBarController:shouldSelectViewController:atIndex:)];
        delegateFlags_.didSelectViewController = [delegate respondsToSelector:@selector(verticalTabBarController:didSelectViewController:atIndex:)];
    }
}

- (UIViewController *)selectedViewController {
    NSAssert(self.selectedIndex < self.viewControllers.count, @"Selected index is invalid");
    
    id selectedViewController = [self.viewControllers objectAtIndex:self.selectedIndex];
    
    if (selectedViewController == [NSNull null]) {
        return nil;
    }
    
    return selectedViewController;
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    NSAssert([self.viewControllers containsObject:selectedViewController], @"View controller must be a part of the TabBar");
    
    // updates the UI
    self.selectedIndex = [self.viewControllers indexOfObject:selectedViewController];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    if (animated) {
        // TODO:
    } else {
        self.viewControllers = viewControllers;
    }
}

- (void)setViewControllers:(NSArray *)viewControllers {
    if (viewControllers != viewControllers_) {
        viewControllers_ = [NSMutableArray arrayWithArray:viewControllers];
        
        [self updateUI];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex != selectedIndex_) {
        selectedIndex_ = selectedIndex;
        
        [self updateUI];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)updateUI {
    // TODO: Update UI depending on current state
}

- (CGFloat)askDelegateForWidthOfTabBar {
    if (delegateFlags_.widthOfTabBar) {
        return [self.delegate widthOfTabBarOfVerticalTabBarController:self];
    }
    
    return kNGTabBarControllerDefaultWidth;
}

- (NGVerticalTabBarCell *)askDelegateForCellOfViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    return [self.delegate verticalTabBarController:self cellForViewController:viewController atIndex:index];
}

- (BOOL)askDelegateIfWeShouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    if (delegateFlags_.shouldSelectViewController) {
        return [self.delegate verticalTabBarController:self shouldSelectViewController:viewController atIndex:index];
    }
    
    // default: the view controller can be selected
    return YES;
}

- (void)callDelegateDidSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    if (delegateFlags_.didSelectViewController) {
        [self.delegate verticalTabBarController:self didSelectViewController:viewController atIndex:index];
    }
}

@end
