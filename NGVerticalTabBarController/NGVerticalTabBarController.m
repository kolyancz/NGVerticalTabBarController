#import "NGVerticalTabBarController.h"


// the default width of the tabBar
#define kNGTabBarControllerDefaultWidth     150.0f
#define kNGTabBarCellDefaultHeight          120.0f
#define kNGDefaultAnimationDuration           0.3f
#define kNGScaleFactor                        0.98f
#define kNGScaleDuration                      0.15f


@interface NGVerticalTabBarController () <UITableViewDataSource, UITableViewDelegate> {
    // re-defined as mutable
    NSMutableArray *_viewControllers;
    
    // flags for methods implemented in the delegate
    struct {
        unsigned int widthOfTabBar:1;
        unsigned int heightForTabBarCellAtIndex:1;
		unsigned int shouldSelectViewController:1;
		unsigned int didSelectViewController:1;
	} _delegateFlags;
    
    BOOL _moveScaleAnimationActive;
}

// re-defined as read/write
@property (nonatomic, strong, readwrite) NGVerticalTabBar *tabBar;
/** the (computed) frame of the sub-viewcontrollers */
@property (nonatomic, readonly) CGRect childViewControllerFrame;
@property (nonatomic, assign) NSUInteger oldSelectedIndex;
@property (nonatomic, readonly) BOOL containmentAPISupported;
@property (nonatomic, readonly) UIViewAnimationOptions currentActiveAnimationOptions;

- (void)updateUI;

- (CGFloat)delegatedTabBarWidth;
- (BOOL)delegatedDecisionIfWeShouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
- (void)callDelegateDidSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
- (CGFloat)delegatedHeightOfTabBarCellAtIndex:(NSUInteger)index;

@end


@implementation NGVerticalTabBarController

@synthesize viewControllers = _viewControllers;
@synthesize selectedIndex = _selectedIndex;
@synthesize delegate = _delegate;
@synthesize tabBar = _tabBar;
@synthesize tabBarCellClass = _tabBarCellClass;
@synthesize animation = _animation;
@synthesize animationDuration = _animationDuration;
@synthesize oldSelectedIndex = _oldSelectedIndex;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithDelegate:(id<NGVerticalTabBarControllerDelegate>)delegate {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _tabBarCellClass = [NGVerticalTabBarCell class];
        
        _selectedIndex = NSNotFound;
        _oldSelectedIndex = NSNotFound;
        _animation = NGVerticalTabBarControllerAnimationNone;
        _animationDuration = kNGDefaultAnimationDuration;
        _moveScaleAnimationActive = NO;
        
        // need to call setter here
        self.delegate = delegate;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self init];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.delegate != nil, @"No delegate set");
    
    CGFloat width = [self delegatedTabBarWidth];
    self.tabBar = [[NGVerticalTabBar alloc] initWithFrame:CGRectMake(0.f, 0.f, width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tabBar.dataSource = self;
    self.tabBar.delegate = self;
    [self.view addSubview:self.tabBar];
}

- (void)viewDidUnload {
    self.tabBar.dataSource = nil;
    self.tabBar.delegate = nil;
    self.tabBar = nil;
    
    if (self.containmentAPISupported) {
        [self.selectedViewController removeFromParentViewController];
    } else {
        [self.selectedViewController.view removeFromSuperview];
        self.selectedViewController.view = nil;
    }
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tabBar reloadData];
    
    if (self.selectedIndex != NSNotFound) {
        [self.tabBar selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]
                                 animated:NO
                           scrollPosition:UITableViewScrollPositionNone];
    }
    
    if (!self.containmentAPISupported) {
        [self.selectedViewController viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.containmentAPISupported) {
        [self.selectedViewController viewDidAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!self.containmentAPISupported) {
        [self.selectedViewController viewWillDisappear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (!self.containmentAPISupported) {
        [self.selectedViewController viewDidDisappear:animated];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect childViewControllerFrame = self.childViewControllerFrame;
    
    if (!_moveScaleAnimationActive) {
        for (UIViewController *viewController in self.viewControllers) {
            viewController.view.frame = childViewControllerFrame;
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return [self.selectedViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (!self.containmentAPISupported) {
        [self.selectedViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (!self.containmentAPISupported) {
        [self.selectedViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if (!self.containmentAPISupported) {
        [self.selectedViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NGVerticalTabBarController
////////////////////////////////////////////////////////////////////////

- (void)setDelegate:(id<NGVerticalTabBarControllerDelegate>)delegate {
    if (delegate != _delegate) {
        _delegate = delegate;
        
        // update delegate flags
        _delegateFlags.widthOfTabBar = [delegate respondsToSelector:@selector(widthOfTabBarOfVerticalTabBarController:)];
        _delegateFlags.heightForTabBarCellAtIndex = [delegate respondsToSelector:@selector(heightForTabBarCell:atIndex:)];
        _delegateFlags.shouldSelectViewController = [delegate respondsToSelector:@selector(verticalTabBarController:shouldSelectViewController:atIndex:)];
        _delegateFlags.didSelectViewController = [delegate respondsToSelector:@selector(verticalTabBarController:didSelectViewController:atIndex:)];
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
    if (viewControllers != _viewControllers) {
        if (self.containmentAPISupported) {
            // remove old child view controller
            for (UIViewController *viewController in _viewControllers) {
                [viewController removeFromParentViewController];
            }
        }
        
        _viewControllers = [NSMutableArray arrayWithArray:viewControllers];
        
        CGRect childViewControllerFrame = self.childViewControllerFrame;
        
        // add new child view controller
        for (UIViewController *viewController in _viewControllers) {
            if (self.containmentAPISupported) {
                [self addChildViewController:viewController];
                [viewController didMoveToParentViewController:self];
            }
            
            viewController.view.frame = childViewControllerFrame;
            viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
        
        if (self.selectedIndex == NSNotFound && _viewControllers.count > 0) {
            [self.view addSubview:[[_viewControllers objectAtIndex:0] view]];
            self.selectedIndex = 0;
        } else {
            [self updateUI];
        }
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex != _selectedIndex) {
        self.oldSelectedIndex = _selectedIndex;
        _selectedIndex = selectedIndex;
        
        [self updateUI];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewControllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NGVerticalTabBarCell *cell = [self.tabBarCellClass cellForTabBar:self.tabBar];
    UIViewController *viewController = [self.viewControllers objectAtIndex:indexPath.row];
    
    // give delegate the chance to customize cell
    cell = [self.delegate verticalTabBarController:self
                                    customizedCell:cell
                                 forViewController:viewController
                                           atIndex:indexPath.row];
    
    return cell;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate
////////////////////////////////////////////////////////////////////////

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // ask the delegate if we can select the cell
    if ([self delegatedDecisionIfWeShouldSelectViewController:[self.viewControllers objectAtIndex:indexPath.row] atIndex:indexPath.row]) {
        return indexPath;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // did the selection change?
    if (indexPath.row != self.selectedIndex) {        
        // updates the UI
        self.selectedIndex = indexPath.row;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self delegatedHeightOfTabBarCellAtIndex:[indexPath row]];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)updateUI {
    if (self.selectedIndex != NSNotFound) {
        NSIndexPath *newSelectedIndexPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
        UIViewController *newSelectedViewController = self.selectedViewController;
        [self.tabBar selectRowAtIndexPath:newSelectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
        // show transition between old and new child viewcontroller
        if (self.oldSelectedIndex != NSNotFound) {
            NSIndexPath *oldSelectedIndexPath = [NSIndexPath indexPathForRow:self.oldSelectedIndex inSection:0];
            UIViewController *oldSelectedViewController = [self.viewControllers objectAtIndex:oldSelectedIndexPath.row];
            [self.tabBar deselectRowAtIndexPath:oldSelectedIndexPath animated:NO];
            
            if (self.containmentAPISupported) { 
                // custom move animation
                if (self.animation == NGVerticalTabBarControllerAnimationMove ||
                    self.animation == NGVerticalTabBarControllerAnimationMoveAndScale) {
                    CGRect frame = self.childViewControllerFrame;
                    
                    if (self.oldSelectedIndex < self.selectedIndex) {
                        frame.origin.y = frame.size.height;
                    } else {
                        frame.origin.y = -frame.size.height;
                    }
                    
                    newSelectedViewController.view.frame = frame;
                    
                    if (self.animation == NGVerticalTabBarControllerAnimationMoveAndScale) {
                        _moveScaleAnimationActive = YES;
                        
                        [UIView animateWithDuration:kNGScaleDuration
                                         animations:^{
                                             oldSelectedViewController.view.transform = CGAffineTransformMakeScale(kNGScaleFactor, kNGScaleFactor);
                                             newSelectedViewController.view.transform = CGAffineTransformMakeScale(kNGScaleFactor, kNGScaleFactor);
                                         }];
                    }
                }
                
                // if the user switches tabs too fast the viewControllers disappear from view hierarchy
                // this is a workaround to not allow the user to switch during an animated transition
                self.tabBar.userInteractionEnabled = NO;
                
                [self transitionFromViewController:oldSelectedViewController
                                  toViewController:newSelectedViewController
                                          duration:self.animationDuration
                                           options:self.currentActiveAnimationOptions
                                        animations:^{
                                            if (self.animation == NGVerticalTabBarControllerAnimationMove ||
                                                self.animation == NGVerticalTabBarControllerAnimationMoveAndScale) {
                                                CGRect frame = oldSelectedViewController.view.frame;
                                                
                                                newSelectedViewController.view.frame = frame;
                                                
                                                if (self.oldSelectedIndex < self.selectedIndex) {
                                                    frame.origin.y = -frame.size.height;
                                                } else {
                                                    frame.origin.y = frame.size.height;
                                                }
                                                
                                                oldSelectedViewController.view.frame = frame;
                                            }
                                        } completion:^(BOOL finished) {
                                            self.tabBar.userInteractionEnabled = YES;
                                            
                                            if (self.animation == NGVerticalTabBarControllerAnimationMoveAndScale) {
                                                [UIView animateWithDuration:kNGScaleDuration
                                                                 animations:^{
                                                                     oldSelectedViewController.view.transform = CGAffineTransformMakeScale(1.f, 1.f);
                                                                     newSelectedViewController.view.transform = CGAffineTransformMakeScale(1.f, 1.f);
                                                                 } completion:^(BOOL finished) {
                                                                     newSelectedViewController.view.frame = self.childViewControllerFrame;
                                                                     _moveScaleAnimationActive = NO;
                                                                     
                                                                     // call the delegate that we changed selection
                                                                     [self callDelegateDidSelectViewController:newSelectedViewController atIndex:self.selectedIndex];
                                                                 }];
                                            } else {
                                                // call the delegate that we changed selection
                                                [self callDelegateDidSelectViewController:newSelectedViewController atIndex:self.selectedIndex];
                                            }
                                        }];
            }
            
            // no containment API (< iOS 5)
            else {
                [oldSelectedViewController viewWillDisappear:NO];
                [newSelectedViewController viewWillAppear:NO];
                newSelectedViewController.view.frame = self.childViewControllerFrame;
                [self.view addSubview:newSelectedViewController.view];
                [newSelectedViewController viewDidAppear:NO];
                [oldSelectedViewController.view removeFromSuperview];
                [oldSelectedViewController viewDidDisappear:NO];
                
                // call the delegate that we changed selection
                [self callDelegateDidSelectViewController:newSelectedViewController atIndex:self.selectedIndex];
            }
        }
        
        // no old selected index path
        else {
            if (!self.containmentAPISupported) {
                newSelectedViewController.view.frame = self.childViewControllerFrame;
                [self.view addSubview:newSelectedViewController.view];
            }
        }
    }
}

- (CGRect)childViewControllerFrame {
    CGRect bounds = self.view.bounds;
    CGRect childFrame = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0.f, [self delegatedTabBarWidth]+1.f, 0.f, 0.f));
    
    return childFrame;
}

- (BOOL)containmentAPISupported {
    // containment API is supported on iOS 5 and up
    static BOOL containmentAPISupported;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        containmentAPISupported = ([self respondsToSelector:@selector(willMoveToParentViewController:)] &&
                                   [self respondsToSelector:@selector(didMoveToParentViewController:)] && 
                                   [self respondsToSelector:@selector(transitionFromViewController:toViewController:duration:options:animations:completion:)]);
    });
    
    return containmentAPISupported;
}

- (UIViewAnimationOptions)currentActiveAnimationOptions {
    UIViewAnimationOptions animationOptions = UIViewAnimationOptionTransitionNone;
    
    switch (self.animation) {    
        case NGVerticalTabBarControllerAnimationFade:
            animationOptions = UIViewAnimationOptionTransitionCrossDissolve;
            break;
            
        case NGVerticalTabBarControllerAnimationCurl:
            animationOptions = (self.oldSelectedIndex > self.selectedIndex) ? UIViewAnimationOptionTransitionCurlDown : UIViewAnimationOptionTransitionCurlUp;
            break;
            
        case NGVerticalTabBarControllerAnimationMove:
        case NGVerticalTabBarControllerAnimationMoveAndScale:
            // this animation is done manually.
            animationOptions = UIViewAnimationOptionLayoutSubviews;
            break;
            
            
        case NGVerticalTabBarControllerAnimationNone:
        default:
            // do nothing
            break;
    }
    
    return animationOptions;
}

- (CGFloat)delegatedTabBarWidth {
    if (_delegateFlags.widthOfTabBar) {
        return [self.delegate widthOfTabBarOfVerticalTabBarController:self];
    }
    
    // default width
    return kNGTabBarControllerDefaultWidth;
}

- (BOOL)delegatedDecisionIfWeShouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    if (_delegateFlags.shouldSelectViewController) {
        return [self.delegate verticalTabBarController:self shouldSelectViewController:viewController atIndex:index];
    }
    
    // default: the view controller can be selected
    return YES;
}

- (void)callDelegateDidSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    if (_delegateFlags.didSelectViewController) {
        [self.delegate verticalTabBarController:self didSelectViewController:viewController atIndex:index];
    }
}

- (CGFloat)delegatedHeightOfTabBarCellAtIndex:(NSUInteger)index {
    if (_delegateFlags.heightForTabBarCellAtIndex) {
        return [self.delegate heightForTabBarCell:self atIndex:index];
    }
    
    // default cell height
    return kNGTabBarCellDefaultHeight;
}

@end
