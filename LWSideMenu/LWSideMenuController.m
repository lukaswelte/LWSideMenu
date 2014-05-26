//
// Created by Lukas Welte on 26.05.14.
// Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWSideMenuController.h"

@interface LWSideMenuController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIViewController *menuViewController;
@property (nonatomic, strong) UIViewController *contentViewController;
@property (nonatomic, assign, getter=isMenuOpened) BOOL menuOpened;
@property(nonatomic, strong) UIDynamicAnimator *animator;
@property(nonatomic, strong) UIGravityBehavior *gravityBehaviour;
@property(nonatomic, strong) UIPushBehavior *pushBehavior;
@property(nonatomic, strong) UIAttachmentBehavior *panAttachmentBehaviour;
@property(nonatomic, strong) UIScreenEdgePanGestureRecognizer *leftScreenEdgeGestureRecognizer;
@property(nonatomic, strong) UIScreenEdgePanGestureRecognizer *rightScreenEdgeGestureRecognizer;
@end

@implementation LWSideMenuController {

}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCNotLocalizedStringInspection"
- (id)init {
    NSAssert(NO, @"Use the initializer methods to create the object");
    return nil;
}
#pragma clang diagnostic pop

- (instancetype)initWithMenuViewController:(UIViewController *)menuViewController contentViewController:(UIViewController *)contentViewController {
    NSParameterAssert(menuViewController);
    NSParameterAssert(contentViewController);

    self = [super init];
    if (self) {
        self.menuViewController = menuViewController;
        self.contentViewController = contentViewController;
        self.menuOpened = NO;
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

        self.leftScreenEdgeGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleScreenEdgePan:)];
        self.leftScreenEdgeGestureRecognizer.edges = UIRectEdgeLeft;
        self.leftScreenEdgeGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:self.leftScreenEdgeGestureRecognizer];

        self.rightScreenEdgeGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleScreenEdgePan:)];
        self.rightScreenEdgeGestureRecognizer.edges = UIRectEdgeRight;
        self.rightScreenEdgeGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:self.rightScreenEdgeGestureRecognizer];
    }

    return self;
}

+ (instancetype)controllerWithMenuViewController:(UIViewController *)menuViewController contentViewController:(UIViewController *)contentViewController {
    return [[self alloc] initWithMenuViewController:menuViewController contentViewController:contentViewController];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupContentViewControllerAnimatorProperties];
}

-(void)setupContentViewControllerAnimatorProperties {
    UIView *contentView = self.contentViewController.view;
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[contentView]];
    // Need to create a boundary that lies to the left off of the right edge of the screen.
    [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, 0, 0, -280)];
    [self.animator addBehavior:collisionBehaviour];

    self.gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[contentView]];
    self.gravityBehaviour.gravityDirection = CGVectorMake(-1, 0);
    [self.animator addBehavior:self.gravityBehaviour];

    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[contentView] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.magnitude = 0.0f;
    self.pushBehavior.angle = 0.0f;
    [self.animator addBehavior:self.pushBehavior];

    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[contentView]];
    itemBehaviour.elasticity = 0.2f;
    [self.animator addBehavior:itemBehaviour];
}

- (void)removeChildViewControllerFromContainer:(UIViewController *)childViewController {
    if(!childViewController) return;
    [childViewController willMoveToParentViewController:nil];
    [childViewController removeFromParentViewController];
    [childViewController.view removeFromSuperview];
}

- (void)setContentViewController:(UIViewController *)contentViewController {
    NSParameterAssert(contentViewController);

    [self removeChildViewControllerFromContainer:_contentViewController];

    _contentViewController = contentViewController;

    [self addChildViewController:_contentViewController];
    [self.view addSubview:_contentViewController.view];
    _contentViewController.view.frame = self.view.frame;
    [self.view bringSubviewToFront:_contentViewController.view];
    [_contentViewController didMoveToParentViewController:self];
}

- (void)setMenuViewController:(UIViewController *)menuViewController {
    NSParameterAssert(menuViewController);
    [self removeChildViewControllerFromContainer:_menuViewController];

    _menuViewController = menuViewController;

    [self addChildViewController:_menuViewController];
    [self.view insertSubview:_menuViewController.view atIndex:0];
    [_menuViewController didMoveToParentViewController:self];
}

- (void)setContentViewController:(UIViewController *)controller animated:(BOOL)animated {
    [self setContentViewController:controller];
}

- (void)toggleMenu {
    if (self.isMenuOpened) {
        [self closeMenu];
    } else {
        [self openMenu];
    }
}

- (void)openMenu {
    self.menuOpened = YES;
}

- (void)closeMenu {
    self.menuOpened = NO;
}

#pragma mark - UIGestureRecognizerDelegate Methods

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.leftScreenEdgeGestureRecognizer && !self.isMenuOpened) {
        return YES;
    }
    else if (gestureRecognizer == self.rightScreenEdgeGestureRecognizer && self.isMenuOpened) {
        return YES;
    }

    return NO;
}

#pragma mark - Gesture Recognizer Methods

-(void)handleScreenEdgePan:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.view];
    UIView *contentView = self.contentViewController.view;
    location.y = CGRectGetMidY(contentView.bounds);

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.animator removeBehavior:self.gravityBehaviour];

        self.panAttachmentBehaviour = [[UIAttachmentBehavior alloc] initWithItem:contentView attachedToAnchor:location];
        [self.animator addBehavior:self.panAttachmentBehaviour];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.panAttachmentBehaviour.anchorPoint = location;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.animator removeBehavior:self.panAttachmentBehaviour], self.panAttachmentBehaviour = nil;

        CGPoint velocity = [gestureRecognizer velocityInView:self.view];

        if (velocity.x > 0) {
            // Open menu
            self.menuOpened = YES;

            self.gravityBehaviour.gravityDirection = CGVectorMake(1, 0);
        }
        else {
            // Close menu
            self.menuOpened = NO;

            self.gravityBehaviour.gravityDirection = CGVectorMake(-1, 0);
        }

        [self.animator addBehavior:self.gravityBehaviour];

        self.pushBehavior.pushDirection = CGVectorMake(velocity.x / 10.0f, 0);
        self.pushBehavior.active = YES;
    }
}
@end