
//
//  EventSpine_Private.c
//  EventSpine
//
//  Created by Hari Karam Singh on 21/07/2014.
//  Copyright (c) 2014 Club 15CC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESDefs.h"
#import "EventSpine_Private.h"


_ESWeakKeyMutableDictionary * _ESListenerEntriesDict;

/////////////////////////////////////////////////////////////////////////
#pragma mark -
/////////////////////////////////////////////////////////////////////////

@implementation _ESListenerEntry

- (instancetype)initWithListener:(id)listener target:(id)target event:(NSString *)event block:(_ESEventBlk)block isListenOnce:(BOOL)isListenOnce listenOnceExclusions:(NSArray *)listenOnceExclusions
{
    NSParameterAssert(listener);
    NSParameterAssert(event);
    NSParameterAssert(target);
    NSParameterAssert(block);
    
    self = [super init];
    if (self) {
        _listener = listener;
        _target = target;
        _event = event;
        _block = block;  // need Block_copy?
        _isListenOnce = isListenOnce;
        _listenOnceExclusions = listenOnceExclusions;
    }
    return self;
}

@end
