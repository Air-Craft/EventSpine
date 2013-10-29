//
//  NSObject+EventSpine.m
//  Marshmallows
//
//  Created by Hari Karam Singh on 01/06/2013.
//  Copyright (c) 2013 Hari Karam Singh. All rights reserved.
//

#import "NSObject+EventSpine.h"
#import <objc/runtime.h>



static const void *_kNSObjectSPEventListeningListenersKey;

@implementation NSObject (SPEventListening)



- (id)listenTo:(NSString *)eventName onObject:(id)targetObj usingBlock:(void (^)(NSNotification *))block
{
    NSAssert(targetObj, @"A target object must be specified!");
    
    return [self listenTo:eventName onObject:targetObj withQueue:[NSOperationQueue mainQueue] usingBlock:block];
}

//---------------------------------------------------------------------

- (id)listenTo:(NSString *)eventName onObject:(id)targetObj withQueue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *notif))block
{
    NSAssert(targetObj, @"A target object must be specified!");

    // Create the observer
    id newListener = [[NSNotificationCenter defaultCenter] addObserverForName:eventName object:targetObj queue:queue usingBlock:block];
    
    // Add the observer to our internal list
    NSMutableSet *listeners = objc_getAssociatedObject(self, _kNSObjectSPEventListeningListenersKey);
    if (!listeners) {
        listeners = [NSMutableSet set];
        objc_setAssociatedObject(self, _kNSObjectSPEventListeningListenersKey, listeners, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [listeners addObject:newListener];
    
    return newListener;
}

//---------------------------------------------------------------------

- (id)listenOnceTo:(NSString *)eventName onObject:(id)targetObj usingBlock:(void (^)(NSNotification *))block
{
    return [self listenOnceTo:eventName
                     onObject:targetObj
                    withQueue:[NSOperationQueue mainQueue]
                   usingBlock:block];
}

//---------------------------------------------------------------------

- (id)listenOnceTo:(NSString *)eventName onObject:(id)targetObj withQueue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *))block
{
    // TODO: We DO need to keep track of this listener as removeAll should remove it if not triggered first
    
    __block id listener;
    listener = [self listenTo:eventName onObject:targetObj withQueue:queue usingBlock:^(NSNotification *note) {
        block(note);
        [self removeListener:listener];
    }];
    return listener;
}

//---------------------------------------------------------------------

- (void)removeListener:(id)listener
{
    NSParameterAssert(listener);
    // Remove from the NSNotif observers
    [[NSNotificationCenter defaultCenter] removeObserver:listener];
    
    // Clear out from our list
    NSMutableSet *listeners = objc_getAssociatedObject(self, _kNSObjectSPEventListeningListenersKey);
    [listeners removeObject:listener];
//    objc_setAssociatedObject(self, _kNSObjectSPEventListeningListenersKey, listeners, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//---------------------------------------------------------------------

- (void)removeAllListeners
{
    NSMutableSet *listeners = objc_getAssociatedObject(self, _kNSObjectSPEventListeningListenersKey);

    // Loop through and remove the observer refs
    for (id listener in listeners) {
        [[NSNotificationCenter defaultCenter] removeObserver:listener];
    }
    
    // Clear our the tracking property and save
    [listeners removeAllObjects];
//    objc_setAssociatedObject(self, _kNSObjectSPEventListeningListenersKey, listeners, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


//---------------------------------------------------------------------

- (void)trigger:(NSString *)eventName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:self];
}

//---------------------------------------------------------------------

- (void)trigger:(NSString *)eventName userInfo:(NSDictionary *)userInfoDict
{
    [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:self userInfo:userInfoDict];
}


@end

/** This function is provided for unit testing purposes; it exposes the listener key, allowing tests to inspect the associated object.  */
const void* _test_SPEventListeningListenersKeyAddr() { return _kNSObjectSPEventListeningListenersKey; }
