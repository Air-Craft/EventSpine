//
//  NSObject+EventSpine.h
//  Marshmallows
//
//  Created by Hari Karam Singh on 01/06/2013.
//  Copyright (c) 2013 Hari Karam Singh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESMeta.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - Defs
/////////////////////////////////////////////////////////////////////////

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


#define ESLocalizeArgs(...) \
    es_metamacro_concat(ESLocalizeArgs, es_metamacro_argcount(__VA_ARGS__))(__VA_ARGS__)


#define ESLocalizeArgs1(VAR1) \
{ \
va_list argList; va_start(argList, target); \
VAR1 = va_arg(argList, __unsafe_unretained __typeof__(VAR1)); \
va_end(argList); \
}

#define ESLocalizeArgs2(VAR1, VAR2) \
{ \
va_list argList; va_start(argList, target); \
__es_var_arg(&argList, &VAR1); \
__es_var_arg(&argList, &VAR2); \
va_end(argList); \
}

#define ESLocalizeArgs3(VAR1, VAR2, VAR3) \
{ \
va_list argList; va_start(argList, target); \
VAR1 = va_arg(argList, id); \
VAR2 = va_arg(argList, id); \
VAR3 = va_arg(argList, id); \
va_end(argList); \
}


typedef void (^ESEventBlk)(id target, ...);



/////////////////////////////////////////////////////////////////////////
#pragma mark -
/////////////////////////////////////////////////////////////////////////

@interface NSObject (SPEventListening)

/** 
 Add a listener to an event name on an object using the block on the main NSOperation queue
 @param obj Must NOT be nil
 @return Opaque object referencing the listener
 */
- (id)listenTo:(NSString *)eventName on:(id)targetObj using:(ESEventBlk)block;

/** 
 Listen to the event only once, removing the observer when it is triggered 
 @return Opaque object referencing the listener
 */
- (id)listenOnceTo:(NSString *)eventName on:(id)targetObj using:(void (^)(NSNotification *notif))block;

- (id)listenOnceTo:(NSString *)eventName on:(id)targetObj using:(void (^)(NSNotification *notif))block persist:(BOOL)shouldPersist;


/** 
 Same as above with a custom queue 
 @return Opaque object referencing the listener
 */
- (id)listenOnceTo:(NSString *)eventName onObject:(id)targetObj withQueue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *notif))block;


// Remove the listener referenced by the opaque object returned from the listen* methods
- (void)removeListener:(id)listener;

/** Remove all event listeners stemming from this object (generally called on dealloc) */
- (void)removeAllListeners;


/** Posts the specified notification for listeners to this object */
- (void)trigger:(NSString *)eventName;

/** Trigger an event with a custom userInfoDict */
- (void)trigger:(NSString *)eventName userInfo:(NSDictionary *)userInfoDict;

@end
