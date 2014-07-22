//
//  UINavigationController+EventSpine.m
//  MixUp
//
//  Created by Hari Karam Singh on 22/07/2014.
//  Copyright (c) 2014 MPC. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+EventSpine.h"
#import "UINavigationController+EventSpine.h"

@implementation UINavigationController (EventSpine)

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self trigger:@"willShowViewController" args:viewController, @(animated), nil];
}

//---------------------------------------------------------------------

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self trigger:@"didShowViewController" args:viewController, @(animated), nil];
}

@end
