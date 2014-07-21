//
//  ListenSpineTests.m
//  ListenSpineTests
//
//  Created by Hari Karam Singh on 22/10/2013.
//  Copyright (c) 2013 Club 15CC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "NSObject+EventSpine.h"

/** Used to check assert an event has been called the number of expected times.  Using a macro to ensure proper indication of failure point */
#define ESAssertEventCallCount(EVENT, CNT) \
    XCTAssertEqualObjects(_tallyDict[EVENT], @(CNT), @"Expected %@ to have been called %i times, %i actual.", EVENT, CNT, [_tallyDict[EVENT] integerValue])


/////////////////////////////////////////////////////////////////////////
#pragma mark -
/////////////////////////////////////////////////////////////////////////

@interface EventSpineTests : XCTestCase
@end


/////////////////////////////////////////////////////////////////////////
#pragma mark -
/////////////////////////////////////////////////////////////////////////

@implementation EventSpineTests
{
    NSObject *obj1, *obj2;                  ///< Dummy objects for use in tests
    void(^tallyBlock)(id target, ...);   ///< Use this for the event callback

    NSMutableDictionary *_tallyDict;        ///< Private tally dict.  No need to access in tests.
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Utility Methods
/////////////////////////////////////////////////////////////////////////

- (void)waitFor:(NSTimeInterval)seconds
{
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:seconds];
    while ([loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Prep
/////////////////////////////////////////////////////////////////////////


- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    obj1 = [[NSObject alloc] init];
    obj2 = [[NSObject alloc] init];
    _tallyDict = [NSMutableDictionary dictionaryWithCapacity:2];
    __weak typeof(self) wself = self;
    
    // Add one to the dict entry with the given event name
    tallyBlock = ^(NSNotification*n){
        __strong __typeof__(wself) self = wself;
        id count = [self->_tallyDict objectForKey:n.name];
        self->_tallyDict[n.name] = @(count ? [count integerValue]+1 : 1);
    };
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}



/////////////////////////////////////////////////////////////////////////
#pragma mark - Tests
/////////////////////////////////////////////////////////////////////////

- (void)testListenWithStringEvents
{
    [obj1 listenTo:@"event1" on:obj2 do:tallyBlock];
    [obj1 listenTo:@"event2" on:obj2 do:tallyBlock];
    [obj1 listenTo:@"event3" on:obj2 do:tallyBlock];
    
    [obj2 trigger:@"event1"];
    [obj2 trigger:@"event2"];
    [obj2 trigger:@"event2"];
    [obj2 trigger:@"nonEvent"];

    [self waitFor:0.1];
    
    ESAssertEventCallCount(@"event1", 1);
    ESAssertEventCallCount(@"event2", 2);
    ESAssertEventCallCount(@"event3", 0);

//    [obj1 listenOnceTo:@"hu" on:Nil do:^(NSNotification *evt) {
//        <#code#>
//    }];
//    
//    [obj1 listenOnceTo:@"hu" on:Nil do:^(id target, NSString *evt, NSDictionary *args) {
//        <#code#>
//    }];
//
//    
//    [obj1 listenOnceTo:@"hu" on:Nil do:^(ESEvent *evt) {
//        evt.name
//        evt.args
//    }];
//
//
}

//---------------------------------------------------------------------

- (void)testSubEventSyntax
{
    [obj1 listenTo:@"api" on:obj2 do:tallyBlock];
    [obj1 listenTo:@"api.success" on:obj2 do:tallyBlock];
    [obj1 listenTo:@"api.fetchModel" on:obj2 do:tallyBlock];
    [obj1 listenTo:@"api.fetchModel.success" on:obj2 do:tallyBlock];
    
    [obj2 trigger:@"api"];
    [obj2 trigger:@"api.fetchModel.success"];
    
    [self waitFor:0.1];

    ESAssertEventCallCount(@"api", 2);
    ESAssertEventCallCount(@"api.success", 0);
    ESAssertEventCallCount(@"api.fetchModel", 1);
    ESAssertEventCallCount(@"api.fetchModel.success", 2);
}

//---------------------------------------------------------------------

- (void)testListenToOnce
{
    [obj1 listenOnceTo:@"g" on:obj2 do:tallyBlock];
    [obj1 listenOnceTo:@"h" on:obj2 do:tallyBlock];
    [obj2 trigger:@"g"];
    [obj2 trigger:@"h"];

    [self waitFor:0.1];
    ESAssertEventCallCount(@"g", 1);
    ESAssertEventCallCount(@"h", 1);
}

//---------------------------------------------------------------------

- (void)testListenOnceToUnless
{
    // Mutex
    [obj1 listenOnceTo:@"success" unless:@"error" on:obj2 do:tallyBlock];
    [obj1 listenOnceTo:@"error" unless:@"success" on:obj2 do:tallyBlock];
    [obj2 trigger:@"success"];
    [obj2 trigger:@"error"];
    [obj2 trigger:@"success"];
    [self waitFor:0.1];
    ESAssertEventCallCount(@"success", 1);
    ESAssertEventCallCount(@"error", 0);
}

//---------------------------------------------------------------------

- (void)testRemoveListenerById
{
    ESListener listener = [obj1 listenTo:@"a" on:obj2 do:tallyBlock];
    [obj1 listenTo:@"b" on:obj2 do:tallyBlock];
    [obj2 trigger:@"a"];
    [obj2 trigger:@"b"];
    [obj1 removeListener:listener];
    [obj2 trigger:@"a"];
    [obj2 trigger:@"b"];
    ESAssertEventCallCount(@"a", 1);
    ESAssertEventCallCount(@"b", 2);
}

- (void)testRemoveListenerByEventName
{
    [obj1 listenTo:@"a" on:obj2 do:tallyBlock];
    [obj1 listenTo:@"b" on:obj2 do:tallyBlock];
    [obj1 listenTo:@"c" on:obj2 do:tallyBlock];
    [obj2 trigger:@"a"];
    [obj2 trigger:@"b"];
    [obj2 trigger:@"c"];
    [obj1 removeListenersFor:@[@"a", @"b"]];
    [obj2 trigger:@"a"];
    [obj2 trigger:@"b"];
    [obj2 trigger:@"c"];
    [obj1 removeListenersFor:@"c"];
    [obj2 trigger:@"a"];
    [obj2 trigger:@"b"];
    [obj2 trigger:@"c"];
    ESAssertEventCallCount(@"a", 1);
    ESAssertEventCallCount(@"b", 1);
    ESAssertEventCallCount(@"c", 2);
}

- (void)testRemoveAllListeners
{
    [obj1 listenTo:@"a" on:obj2 do:tallyBlock];
    [obj1 listenTo:@"b" on:obj2 do:tallyBlock];
    [obj2 trigger:@"a"];
    [obj2 trigger:@"b"];
    [obj1 removeAllListeners];
    [obj2 trigger:@"a"];
    [obj2 trigger:@"b"];
    ESAssertEventCallCount(@"a", 1);
    ESAssertEventCallCount(@"b", 1);
}

//---------------------------------------------------------------------

- (void)testEventArgs
{
}

@end
