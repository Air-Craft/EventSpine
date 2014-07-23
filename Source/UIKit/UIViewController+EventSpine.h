//
//  UIViewController+EventSpine.h
//  MixUp
//
//  Created by Hari Karam Singh on 22/07/2014.
//  Copyright (c) 2014 MPC. All rights reserved.
//

#import <UIKit/UIKit.h>


/** 
 Adds event hooks into UIVC events like `prepareForSegue:sender:`.  Uses swizzling so you can still access these methods directly
 
 @triggers "prepareForSegue" (UIStoryboardSegue *segue, id sender)
 */
@interface UIViewController (EventSpine)

/** Call to swizzle out the messages */
+ (void)useEventSpine;

@end
