//
//  NSObject+EventSpine.h
//  Marshmallows
//
//  Created by Hari Karam Singh on 01/06/2013.
//  Copyright (c) 2013 Hari Karam Singh. All rights reserved.
//

#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////////////////////////
#pragma mark - Defs
/////////////////////////////////////////////////////////////////////////

@class _ESListenerEntry;

/** Opaque type representing the listener object returned when you register to listen to an event */
typedef _ESListenerEntry *ESListener;


//#ifndef weakify
//#define weakify(VAR) \
//    try {} @finally {} \
//    __weak __typeof__(VAR) VAR ## _weak_ = (VAR);
//#endif
//
//#ifndef strongify
//#define strongify(VAR) \
//    try {} @finally {} \
//    _Pragma("clang diagnostic push") \
//    _Pragma("clang diagnostic ignored \"-Wshadow\"") \
//    __strong __typeof__(VAR) VAR = VAR ## _weak_; \
//    _Pragma("clang diagnostic pop")
//#endif




/////////////////////////////////////////////////////////////////////////
#pragma mark -
/////////////////////////////////////////////////////////////////////////

@interface NSObject (EventSpine)

/** 
 Add a listener to an event name on an object using the block
 
 @param obj Must NOT be nil
 @return Opaque object referencing the listener
 @return
 */
- (ESListener)listenTo:(NSString *)event on:(id)target do:(id)block;

/** 
 Listen to an event for one occurrence and then remove the listener. Allows for simple one off event hooks like when you have block callbacks on a method

 @param     eventName
 @return    Opaque object referencing the listener
 */
- (ESListener)listenOnceTo:(NSString *)event on:(id)target do:(id)block;

- (ESListener)listenOnceTo:(NSString *)event on:(id)target unless:(id)cancelingEventsStringOrArray do:(id)block;


/** Remove the listener referenced by the opaque object returned from the listen* methods */
- (void)stopListeningToTarget:(id)target;
- (void)stopListeningToEvent:(NSString *)event;
- (void)stopListeningToAll;


/** Posts the specified notification for listeners to this object */
- (void)trigger:(NSString *)event;

/** Trigger an event with a custom userInfoDict */
- (void)trigger:(NSString *)event args:(id)arg1, ... NS_REQUIRES_NIL_TERMINATION;

@end
