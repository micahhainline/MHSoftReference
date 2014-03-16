/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 Micah Hainline
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

// The latest version of this file can always be found at https://github.com/micahhainline/MHSoftReference

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "MHSoftMutableArray.h"
#import "MHSoftReferenceTestUtils.h"
#import "MHSoftMutableDictionary.h"

@interface MHSoftMutableDictionaryTest : XCTestCase {
    __strong NSObject *strong1;
    __weak NSObject *weak1;
    __strong NSObject *strong2;
    __weak NSObject *weak2;
    __strong NSObject *strong3;
    __weak NSObject *weak3;
}

@end


@implementation MHSoftMutableDictionaryTest

- (void)setUp {
    [super setUp];
    strong1 = [[NSObject alloc] init];
    weak1 = strong1;
    strong2 = [[NSObject alloc] init];
    weak2 = strong2;
    strong3 = [[NSObject alloc] init];
    weak3 = strong3;
}

- (void)testWhenDictionaryHasObjectsAddedThenTheyCanBeRetrieved {
    MHSoftMutableDictionary *testObject = [MHSoftMutableDictionary dictionary];
    testObject[@"A"] = strong1;
    testObject[@"B"] = strong2;

    XCTAssertEqual(testObject.count, 2u);
    MHSafeAssertEqualObjects(testObject[@"A"], strong1);
    MHSafeAssertEqualObjects(testObject[@"B"], strong2);
}

- (void)testWhenDictionaryIsInitWithObjectsThenTheyCanBeRetrieved {
    MHSoftMutableDictionary *testObject = [MHSoftMutableDictionary dictionaryWithObject:strong1 forKey:@"A"];
    testObject[@"B"] = strong2;

    XCTAssertEqual(testObject.count, 2u);
    MHSafeAssertEqualObjects(testObject[@"A"], strong1);
    MHSafeAssertEqualObjects(testObject[@"B"], strong2);
}

- (void)testWhenObjectsAreRemovedOrAddedThenArrayReturnsCorrectResults {
    MHSoftMutableDictionary *testObject = [MHSoftMutableDictionary dictionaryWithCapacity:3];
    testObject[@"A"] = strong3;
    testObject[@"B"] = strong2;
    testObject[@"A"] = strong1;
    testObject[@"C"] = strong3;

    XCTAssertEqual(testObject.count, 3u);

    MHSafeAssertEqualObjects(testObject[@"A"], strong1);
    MHSafeAssertEqualObjects(testObject[@"B"], strong2);
    MHSafeAssertEqualObjects(testObject[@"C"], strong3);
}

- (void)testWhenObjectsAreAddedThenKeysetIsCorrect {
    MHSoftMutableDictionary *testObject = [MHSoftMutableDictionary dictionary];
    testObject[@"A"] = strong3;
    testObject[@"B"] = strong2;
    testObject[@"A"] = strong1;
    testObject[@"C"] = strong3;

    NSArray *keys = testObject.allKeys;
    XCTAssertEqual(keys.count, 3u);
    XCTAssertTrue([keys containsObject:@"A"]);
    XCTAssertTrue([keys containsObject:@"B"]);
    XCTAssertTrue([keys containsObject:@"C"]);
}

- (void)testWhenMemoryIsLowThenOnlyStrongReferencesAreRetainedInTheList {
    MHSoftMutableDictionary *testObject = [MHSoftMutableDictionary dictionary];
    testObject[@"A"] = strong1;
    testObject[@"B"] = strong2;
    testObject[@"C"] = strong3;
    strong1 = nil;
    strong3 = nil;

    XCTAssertEqual(testObject.count, 3u);
    MHSafeAssertEqualObjects(testObject[@"A"], weak1);
    MHSafeAssertEqualObjects(testObject[@"B"], weak2);
    MHSafeAssertEqualObjects(testObject[@"C"], weak3);
    MHSafeAssertNotNil(weak1);
    MHSafeAssertNotNil(weak3);

    [self fireLowMemory];

    XCTAssertEqual(testObject.count, 1u);
    MHSafeAssertEqualObjects(testObject[@"B"], weak2);
    MHSafeAssertNil(weak1);
    MHSafeAssertNil(weak3);
}

- (void)fireLowMemory {
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

@end