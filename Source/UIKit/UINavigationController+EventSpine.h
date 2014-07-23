//
//  UINavigationController+EventSpine.h
//  MixUp
//
//  Created by Hari Karam Singh on 22/07/2014.
//  Copyright (c) 2014 MPC. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 
 Set UINavVC's delegate to self to utilise this feature.  Overrides the delegate getter and forces it to self.  If you implement overrides in your subclass then be sure to call super
 
 @triggers "willShowViewController" (UIViewController destinationVC, NSNumber *animated)

 @triggers "didShowViewController" (UIViewController destinationVC, NSNumber *animated)
 */
@interface UINavigationController (EventSpine) <UINavigationControllerDelegate>

@end
