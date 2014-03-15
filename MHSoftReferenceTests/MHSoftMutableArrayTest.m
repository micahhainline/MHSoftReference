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

@interface MHSoftMutableArrayTest : XCTestCase {
    __strong NSObject *strong1;
    __weak NSObject *weak1;
    __strong NSObject *strong2;
    __weak NSObject *weak2;
    __strong NSObject *strong3;
    __weak NSObject *weak3;
}

@end


@implementation MHSoftMutableArrayTest

- (void)setUp {
    [super setUp];
    strong1 = [[NSObject alloc] init];
    weak1 = strong1;
    strong2 = [[NSObject alloc] init];
    weak2 = strong2;
    strong3 = [[NSObject alloc] init];
    weak3 = strong3;
}

- (void)testWhenArrayHasObjectsAddedThenTheyCanBeRetrieved {
    MHSoftMutableArray *testObject = [MHSoftMutableArray array];
    [testObject addObject:strong1];
    [testObject addObject:strong2];

    XCTAssertEqual(testObject.count, 2u);
    MHSafeAssertEqualObjects(testObject[0], strong1);
    MHSafeAssertEqualObjects(testObject[1], strong2);
}

- (void)testWhenObjectsAreRemovedOrAddedThenArrayReturnsCorrectResults {
    MHSoftMutableArray *testObject = [MHSoftMutableArray arrayWithCapacity:3];
    [testObject addObject:strong2];
    [testObject insertObject:strong1 atIndex:0];
    [testObject addObject:strong3];
    [testObject addObject:strong1];

    XCTAssertEqual(testObject.count, 4u);

    [testObject removeLastObject];

    XCTAssertEqual(testObject.count, 3u);
    MHSafeAssertEqualObjects(testObject[0], strong1);
    MHSafeAssertEqualObjects(testObject[1], strong2);
    MHSafeAssertEqualObjects(testObject[2], strong3);

    [testObject replaceObjectAtIndex:1 withObject:@"other"];

    XCTAssertEqual(testObject[1], @"other");
}

- (void)testWhenMemoryIsLowThenOnlyStrongReferencesAreRetainedInTheList {
    MHSoftMutableArray *testObject = [MHSoftMutableArray array];
    [testObject addObject:strong1];
    [testObject addObject:strong2];
    [testObject addObject:strong3];
    strong1 = nil;
    strong3 = nil;

    XCTAssertEqual(testObject.count, 3u);
    MHSafeAssertEqualObjects(testObject[0], weak1);
    MHSafeAssertEqualObjects(testObject[1], weak2);
    MHSafeAssertEqualObjects(testObject[2], weak3);
    MHSafeAssertNotNil(weak1);
    MHSafeAssertNotNil(weak3);

    [self fireLowMemory];

    XCTAssertEqual(testObject.count, 1u);
    MHSafeAssertEqualObjects(testObject[0], weak2);
    MHSafeAssertNil(weak1);
    MHSafeAssertNil(weak3);
}

- (void)fireLowMemory {
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

@end