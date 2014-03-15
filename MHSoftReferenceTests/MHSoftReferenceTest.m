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
#import "MHSoftReference.h"
#import "MHSoftReferenceTestUtils.h"

@interface MHSoftReferenceTest : XCTestCase {
    __strong NSObject *strong1;
    __weak NSObject *weak1;
    __strong NSObject *strong2;
    __weak NSObject *weak2;
}

@end


@implementation MHSoftReferenceTest

- (void)setUp {
    [super setUp];
    strong1 = [[NSObject alloc] init];
    weak1 = strong1;
    strong2 = [[NSObject alloc] init];
    weak2 = strong2;
}

- (void)testWhenNoLowMemoryBlockIsSentThenMemoryIsRetained {
    MHSoftReference *soft = [MHSoftReference reference:strong1];
    strong1 = nil;
    
    MHSafeAssertNotNil(weak1);
    MHSafeAssertEqualObjects(soft.value, weak1);
}

- (void)testWhenHardReferenceExistsAndLowMemoryThenValueIsRetained {
    MHSoftReference *soft = [MHSoftReference reference:strong1];
    
    [self fireLowMemory];
    
    MHSafeAssertEqualObjects(soft.value, strong1);
}

- (void)testWhenSingleSoftReferenceExistsANoStrongReferenceExistAndLowMemoryThenValueIsReleased {
    MHSoftReference *soft = [MHSoftReference reference:strong1];
    strong1 = nil;
    
    [self fireLowMemory];
    
    MHSafeAssertNil(weak1);
    MHSafeAssertNil(soft.value);
}

- (void)testWhenSoftReferencesExistToDifferentObjectsAndLowMemoryThenAllObjectsAreCleared {
    MHSoftReference *soft1 = [MHSoftReference reference:strong1];
    MHSoftReference *soft2 = [MHSoftReference reference:strong2];
    strong1 = nil;
    strong2 = nil;
    
    MHSafeAssertNotNil(weak1);
    MHSafeAssertEqualObjects(soft1.value, weak1);
    MHSafeAssertNotNil(weak2);
    MHSafeAssertEqualObjects(soft2.value, weak2);
    
    [self fireLowMemory];
    
    MHSafeAssertNil(weak1);
    MHSafeAssertNil(soft1.value);
    MHSafeAssertNil(weak2);
    MHSafeAssertNil(soft2.value);
}

- (void)testWhenTwoSoftReferencesExistToTheSameObjectAndLowMemoryThenObjectIsCleared {
    MHSoftReference *soft1 = [MHSoftReference reference:strong1];
    MHSoftReference *soft2 = [MHSoftReference reference:strong1];
    strong1 = nil;
    
    [self fireLowMemory];
    
    MHSafeAssertNil(weak1);
    MHSafeAssertNil(soft1.value);
    MHSafeAssertNil(soft2.value);
}

- (void)fireLowMemory {
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

@end