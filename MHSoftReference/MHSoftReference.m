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

#import "MHSoftReference.h"

#define MHSoftReferenceLowMemoryWeakConversionComplete @"MHSoftReferenceLowMemoryWeakConversionComplete"

@interface MHSoftReference() {
    __weak id weakValue;
    __strong id strongValue;
}

@end

@implementation MHSoftReference

static int softReferenceCount = 0;
static int softReferenceWeakConversionCount = 0;

+ (MHSoftReference *)softReference:(id)value {
    return [[MHSoftReference alloc] initWithValue:value];
}

- (instancetype)initWithValue:(id)value {
    self = [super init];
    strongValue = value;
    weakValue = value;
    @synchronized (MHSoftReference.class) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lowMemoryStarted) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lowMemoryEnded) name:MHSoftReferenceLowMemoryWeakConversionComplete object:nil];
        softReferenceCount++;
    }
    return self;
}

- (void)dealloc {
    @synchronized (MHSoftReference.class) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        softReferenceCount--;
    }
}

- (id)value {
    return weakValue;
}

- (void)lowMemoryStarted {
    strongValue = nil;
    softReferenceWeakConversionCount++;
    if (softReferenceCount == softReferenceWeakConversionCount) {
        softReferenceWeakConversionCount = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:MHSoftReferenceLowMemoryWeakConversionComplete object:nil];
    }
}

- (void)lowMemoryEnded {
    strongValue = weakValue;
}

@end