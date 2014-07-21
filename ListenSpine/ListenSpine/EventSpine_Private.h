//
//  EventSpine_Private.h
//  EventSpine
//
//  Created by Hari Karam Singh on 21/07/2014.
//  Copyright (c) 2014 Club 15CC. All rights reserved.
//

#ifndef EventSpine_EventSpine_Private_h
#define EventSpine_EventSpine_Private_h

#import "_ESWeakKeyMutableDictionary.h"
#import "ESDefs.h"

/** Target -> Array of _ESListenerEntry */
extern _ESWeakKeyMutableDictionary * _ESListenerEntriesDict;


/////////////////////////////////////////////////////////////////////////
#pragma mark -
/////////////////////////////////////////////////////////////////////////

/** Block type for casting supplied (type id) blocks before calling */
typedef void (^_ESEventBlk)(id target, ...);

/////////////////////////////////////////////////////////////////////////
#pragma mark -
/////////////////////////////////////////////////////////////////////////

/** Private class used to store a reference to the trigger block and various settings related to it. */
@interface _ESListenerEntry : NSObject

@property (nonatomic, weak, readonly) id listener;
@property (nonatomic, weak, readonly) id target;
@property (nonatomic, copy, readonly) NSString *event;
@property (nonatomic, copy, readonly) _ESEventBlk block;
@property (nonatomic, readonly) BOOL isListenOnce;
@property (nonatomic, strong, readonly) NSArray *listenOnceExclusions;

/** listenerObj and target must not be nil */
- (instancetype)initWithListener:(id)listener
                          target:(id)target
                           event:(NSString *)event
                           block:(_ESEventBlk)block
                    isListenOnce:(BOOL)isListenOnce
            listenOnceExclusions:(NSArray *)listenOnceExclusions;

@end


#endif
