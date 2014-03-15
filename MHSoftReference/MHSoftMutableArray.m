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

#import "MHSoftMutableArray.h"
#import "MHSoftReference.h"
#import "MHSoftReferencePrivateConstants.h"

@interface MHSoftMutableArray ()

@property (nonatomic, readonly) NSMutableArray *array;

@end

@implementation MHSoftMutableArray

#define DEFAULT_CAPACITY 10

+ (instancetype)array {
    return [[self alloc] init];
}

+ (instancetype)arrayWithCapacity:(NSUInteger)numItems {
    return [[self alloc] initWithCapacity:numItems];
}

- (instancetype)init {
    return [self initWithCapacity:DEFAULT_CAPACITY];
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    self = [super init];
    _array = [NSMutableArray arrayWithCapacity:numItems];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(softReferencesUpdated) name:MHSoftReferenceLowMemoryWeakConversionComplete object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addObject:(id)anObject {
    [self insertObject:anObject atIndex:self.count];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    [self.array insertObject:[MHSoftReference reference:anObject] atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [self.array removeObjectAtIndex:index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [self.array replaceObjectAtIndex:index withObject:[MHSoftReference reference:anObject]];
}

- (NSUInteger)count {
    return self.array.count;
}

- (id)objectAtIndex:(NSUInteger)index {
    MHSoftReference *reference = self.array[index];
    return reference.value;
}

- (void)softReferencesUpdated {
    NSMutableArray *deadReferences = [NSMutableArray array];
    for (MHSoftReference *reference in self.array) {
        if (!reference.value) {
            [deadReferences addObject:reference];
        }
    }
    [self.array removeObjectsInArray:deadReferences];
}

@end