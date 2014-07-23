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

+ (void)useEventSpine
{
    // Copies the method to a new selector name, allowing methods to be "swizzled in" to their places expected by the delegate
    void (^swizzleInOnly)(Class, SEL, SEL) = ^(Class c, SEL orig, SEL new){
        Method newMethod = class_getInstanceMethod(c, new);
        class_replaceMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    };
    
    // will/didShowViewController:...
    swizzleInOnly(self.class, @selector(navigationController:didShowViewController:animated:), @selector(_es_navigationController:didShowViewController:animated:));
    swizzleInOnly(self.class, @selector(navigationController:willShowViewController:animated:), @selector(_es_navigationController:willShowViewController:animated:));
    
    // delegate (forced to self)
    swizzleInOnly(self.class, @selector(delegate), @selector(_es_delegate));
    swizzleInOnly(self.class, @selector(setDelegate:), @selector(_es_setDelegate:));
}


- (void)_es_navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self trigger:@"willShowViewController" args:viewController, @(animated), nil];
}

//---------------------------------------------------------------------

- (void)_es_navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self trigger:@"didShowViewController" args:viewController, @(animated), nil];
}


//---------------------------------------------------------------------

- (id<UINavigationControllerDelegate>)_es_delegate
{
    return self;
}

//---------------------------------------------------------------------

- (void)_es_setDelegate:(id<UINavigationControllerDelegate>)delegate
{
    @throw [NSException exceptionWithName:NSGenericException reason:@"Can't set delegate with using EventSpine (delegate=self).  Subclass if you want access to the methods (but call super!)" userInfo:nil];
}


@end
