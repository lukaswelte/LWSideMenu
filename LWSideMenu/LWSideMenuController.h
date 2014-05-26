//
// Created by Lukas Welte on 26.05.14.
// Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LWSideMenuController : UIViewController
@property (nonatomic, readonly) UIViewController *menuViewController;
@property (nonatomic, readonly) UIViewController *contentViewController;
@property (nonatomic, readonly, getter=isMenuOpened) BOOL menuOpened;

- (instancetype)initWithMenuViewController:(UIViewController *)menuViewController contentViewController:(UIViewController *)contentViewController;

+ (instancetype)controllerWithMenuViewController:(UIViewController *)menuViewController contentViewController:(UIViewController *)contentViewController;

- (void)setContentViewController:(UIViewController *)controller animated:(BOOL)animated;

- (void)toggleMenu;
@end