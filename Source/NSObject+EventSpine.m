//
//  NSObject+EventSpine.m
//  Marshmallows
//
//  Created by Hari Karam Singh on 01/06/2013.
//  Copyright (c) 2013 Hari Karam Singh. All rights reserved.
//

#import <objc/runtime.h>
#import "EventSpine_Private.h"
#import "_ESWeakKeyMutableDictionary.h"
#import "NSObject+EventSpine.h"


@implementation NSObject (EventSpine)

/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (ESListener)listenTo:(NSString *)event on:(id)target do:(id)block
{
    // Create and add the listener
    _ESListenerEntry *lst = [[_ESListenerEntry alloc] initWithListener:self target:target event:event block:block isListenOnce:NO listenOnceExclusions:nil];
    
    [self _es_addListener:lst forTarget:target];
    
    return lst;
}

//---------------------------------------------------------------------

- (ESListener)listenOnceTo:(NSString *)event on:(id)target do:(id)block
{
    return [self listenOnceTo:event on:target unless:nil do:block];
}

//---------------------------------------------------------------------

- (ESListener)listenOnceTo:(NSString *)event on:(id)target unless:(id)cancelingEventsStringOrArray do:(id)block
{
    // Normalise string/array dual input
    // Do it here to save a few cpu cycles on trigger which usually needs more performance in an app
    NSArray *cancelingEvents = [self _es_normaliseStringArrayDualInput:cancelingEventsStringOrArray];
    
    _ESListenerEntry *lst = [[_ESListenerEntry alloc] initWithListener:self target:target event:event block:block isListenOnce:YES listenOnceExclusions:cancelingEvents];
    
    [self _es_addListener:lst forTarget:target];
    
    return lst;
    
}

//---------------------------------------------------------------------

- (void)trigger:(NSString *)event
{
    [self trigger:event args:nil];
}

//---------------------------------------------------------------------

- (void)trigger:(NSString *)event args:(id)arg1, ... 
{
    
    // First handle the exclusions....
    // Loop through a copy so we can mutate/remove one-off listeners
    for (_ESListenerEntry *entry in [self _es_allListenerEntries]) {
        if ([entry.listenOnceExclusions containsObject:event]) {
            [self _es_removeListenerEntry:entry];
        }
    }
    
    // Now the triggers.  Copy again so we can remove one-offs
    NSMutableArray *listeners = [self _es_listenerEntriesForTarget:self];
    
    for (_ESListenerEntry *listener in [listeners copy]) {
        // Remove one-offs
        if (listener.isListenOnce) {
            [listeners removeObject:listener];
        }
        
        // Check that the events match
        if (![listener.event isEqualToString:event]) {
            continue;
        }
        
        // Collect the arguments into an array
        va_list args;
        va_start(args, arg1);
        NSMutableArray *argsArr = NSMutableArray.array;
        for (id arg = arg1; arg != nil; arg = va_arg(args, id)) {
            [argsArr addObject:arg];
        }
        va_end(args);
        
        // Now call the block with the correct param count
        NSArray *a = argsArr;
        switch (a.count) {
            case 0: listener.block(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil); break;
            case 1: listener.block(a[0], nil, nil, nil, nil, nil, nil, nil, nil, nil, nil); break;
            case 2: listener.block(a[0], a[1], nil, nil, nil, nil, nil, nil, nil, nil, nil); break;
            case 3: listener.block(a[0], a[1], a[2], nil, nil, nil, nil, nil, nil, nil, nil); break;
            case 4: listener.block(a[0], a[1], a[2], a[3], nil, nil, nil, nil, nil, nil, nil); break;
            case 5: listener.block(a[0], a[1], a[2], a[3], a[4], nil, nil, nil, nil, nil, nil); break;
            case 6: listener.block(a[0], a[1], a[2], a[3], a[4], a[5], nil, nil, nil, nil, nil); break;
            case 7: listener.block(a[0], a[1], a[2], a[3], a[4], a[5], a[6], nil, nil, nil, nil); break;
            case 8: listener.block(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], nil, nil, nil); break;
            case 9: listener.block(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], nil, nil); break;
            case 10: listener.block(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], nil); break;
            case 11: listener.block(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10]); break;
            default:
                [NSException raise:NSInvalidArgumentException format:@"Maximum 11 paramaters please."];
                break;
        }    
    }
}

//---------------------------------------------------------------------


- (void)stopListeningToTarget:(id)target
{
    [_ESListenerEntriesDict removeObjectForKey:target];
}

//---------------------------------------------------------------------

- (void)stopListeningToEvent:(NSString *)event
{
    // Iterate through and remove entries with the event name
    for (NSMutableArray *entries in _ESListenerEntriesDict) {
        for (_ESListenerEntry *entry in entries.copy) {
            if ([entry.event isEqualToString:event]) {
                [entries removeObject:entry];
            }
        }
    }
}

//---------------------------------------------------------------------

- (void)stopListeningToAll
{
    // Remove those whose source listener is self
    for (NSMutableArray *entries in _ESListenerEntriesDict) {
        for (_ESListenerEntry *entry in entries.copy) {
            if (entry.listener == self) {
                [entries removeObject:entry];
            }
        }
    }
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////

- (NSMutableArray *)_es_listenerEntriesForTarget:(id)target
{
    // Allocate the main dict if needed
    if (!_ESListenerEntriesDict) {
        _ESListenerEntriesDict = [_ESWeakKeyMutableDictionary dictionary];
    }
    
    // Check for the entry for the target and alloc if needed
    NSMutableArray *listeners = [_ESListenerEntriesDict objectForKey:target];
    if (!listeners) {
        listeners = NSMutableArray.array;
        [_ESListenerEntriesDict setObject:listeners forKey:target];
    }
    
    return listeners;
}

//---------------------------------------------------------------------

- (void)_es_addListener:(_ESListenerEntry *)entry forTarget:(id)target
{
    NSMutableArray *targetEntries = [self _es_listenerEntriesForTarget:target];
    [targetEntries addObject:entry];
}


//---------------------------------------------------------------------

/** Safe to enumerate through */
- (NSArray *)_es_allListenerEntries
{
    NSMutableArray *allEntries = NSMutableArray.array;
    
    for (id key in _ESListenerEntriesDict) {
        [allEntries addObjectsFromArray:[_ESListenerEntriesDict objectForKey:key]];
    }
    
    return allEntries;
}

//---------------------------------------------------------------------

- (void)_es_removeListenerEntry:(_ESListenerEntry *)entryToRemove
{
    // could be anywhere so we need to be careful
    for (id key in _ESListenerEntriesDict) {
        NSMutableArray *entries = [_ESListenerEntriesDict objectForKey:key];
        for (_ESListenerEntry *entry in entries.copy) {
            if ([entry isEqual:entryToRemove]) {
                [entries removeObject:entry];
            }
        }
    }
}

//---------------------------------------------------------------------

/**
 If NSString convert to an array containing the string.  If array then just return as is.  If nil return nil.  If anything else throw exception
 */
- (NSArray *)_es_normaliseStringArrayDualInput:(id)input
{
    if (nil == input) return nil;
    if ([input isKindOfClass:[NSArray class]]) return input;
    
    if (![input isKindOfClass:[NSString class]]) {
        [NSException raise:NSInvalidArgumentException format:@"Array or string expected."];
        return nil;
    }
    
    return @[input];
}

//---------------------------------------------------------------------

// Might bring this back later...

///** E.g. api.fetch.error => ["api", "api.fetch", "api.fetch.error"] */
//- (NSArray *)_es_eventsToTriggerForEventName:(NSString *)eventName
//{
//    NSMutableArray *eventsToTrigger = [NSMutableArray array];
//    
//    NSArray *components = [eventName componentsSeparatedByString:@"."];
//    
//    // Now reassemble the parts
//    int i = 0, cnt = components.count;
//    NSMutableString *evt = [@"" mutableCopy];
//    
//    while (i++ < cnt) {
//        // Period between different subevents
//        if (i > 1) [evt appendString:@"."];
//        
//        [evt appendString:components[i]];
//        [eventsToTrigger addObject:evt.copy];
//    }
//    
//    return eventsToTrigger;
//}

@end

/** This function is provided for unit testing purposes; it exposes the listener key, allowing tests to inspect the associated object.  */
//const void* _test_SPEventListeningListenersKeyAddr() { return _kNSObjectSPEventListeningListenersKey; }
