// Class under test
#import "LWSideMenuController.h"

// Collaborators

// Test support
#import <XCTest/XCTest.h>

@interface LWSideMenuController (test)
@property (nonatomic, strong) UIDynamicAnimator *animator;
- (void)setMenuOpened:(BOOL)menuOpened;
@end

@interface LWSideMenuControllerTest : XCTestCase
@end

@implementation LWSideMenuControllerTest {
    LWSideMenuController *_sideMenuController;
}

- (void)setUp
{
    [super setUp];
    _sideMenuController = [[LWSideMenuController alloc] initWithMenuViewController:[[UIViewController alloc] init] contentViewController:[[UIViewController alloc] init]];
}

- (void)testShouldThrowIfNoViewControllersInParameters {
    XCTAssertThrows([[LWSideMenuController alloc] init], @"Should throw an error, that content and menuViewController is necessary");
}

- (void)testShouldInitializeWithLeftAndContentViewController {
    XCTAssertNotNil([[LWSideMenuController alloc] initWithMenuViewController:[[UIViewController alloc] init] contentViewController:[[UIViewController alloc] init]], @"Should be initializeable with a content view controller");
}

- (void)testShouldProvideClassInitializer {
    XCTAssertNotNil([LWSideMenuController controllerWithMenuViewController:[UIViewController new] contentViewController:[UIViewController new]]);
}

- (void)testShouldBeCorrectlySetUp {
    XCTAssertNotNil(_sideMenuController.animator);
    XCTAssertNotNil(_sideMenuController.contentViewController);
    XCTAssertNotNil(_sideMenuController.menuViewController);
}

- (void)testViewsShouldBeChildViewControllers {
    NSInteger childViewCount = _sideMenuController.childViewControllers.count;
    XCTAssertEqual(childViewCount, 2, @"Controller should have two ChildViewControllers, menu and content View Controller");
}

- (void)testShouldBeAbleToReplaceTheContentViewController {
    _sideMenuController.contentViewController.title = @"Old";
    UIViewController *newContentViewController = [[UIViewController alloc] init];
    newContentViewController.title = @"New";

    [_sideMenuController setContentViewController:newContentViewController animated:NO];

    XCTAssertEqual(_sideMenuController.contentViewController.title, @"New", @"The ContentViewController should be replaced by the new one");
}

- (void)testContentViewControllerShouldBeInFront {
    XCTAssert([_sideMenuController.view.subviews.lastObject isEqual:_sideMenuController.contentViewController.view], @"Content View Controller should be on top");
}

- (void)testShouldToggleMenuOpenState {
    [_sideMenuController setMenuOpened:NO];

    [_sideMenuController toggleMenu];

    XCTAssertEqual(_sideMenuController.isMenuOpened, YES, @"Menu should now be opened");

    [_sideMenuController toggleMenu];

    XCTAssertEqual(_sideMenuController.isMenuOpened, NO, @"Menu should now be closed");
}

@end