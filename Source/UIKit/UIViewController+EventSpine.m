//
//  UIViewController+EventSpine.m
//  MixUp
//
//  Created by Hari Karam Singh on 22/07/2014.
//  Copyright (c) 2014 MPC. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+EventSpine.h"

@implementation UIViewController (EventSpine)

+ (void)useEventSpine
{
    // Swizzle some methods to override while allowing call to originals
    void (^swizzle)(Class, SEL, SEL) = ^(Class c, SEL orig, SEL new){
        Method origMethod = class_getInstanceMethod(c, orig);
        Method newMethod = class_getInstanceMethod(c, new);
        if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
            class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
        else
            method_exchangeImplementations(origMethod, newMethod);
    };
    
    // PrepareForSegue
    swizzle(self.class, @selector(prepareForSegue:sender:), @selector(_es_prepareForSegue:sender:));
}

//---------------------------------------------------------------------

- (void)_es_prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self trigger:@"prepareForSegue" args:segue, sender, nil];
    [self _es_prepareForSegue:segue sender:sender];
}



@end
