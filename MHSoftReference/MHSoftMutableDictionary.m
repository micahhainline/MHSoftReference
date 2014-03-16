#import "MHSoftMutableDictionary.h"
#import "MHSoftReference.h"
#import "MHSoftReferencePrivateConstants.h"

@interface MHSoftMutableDictionary ()

@property (nonatomic, readonly) NSMutableDictionary *dictionary;

@end

@implementation MHSoftMutableDictionary

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    self = [super init];
    _dictionary = [[NSMutableDictionary alloc] initWithCapacity:numItems];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(softReferencesUpdated) name:MHSoftReferenceLowMemoryWeakConversionComplete object:nil];
    return self;
}

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)count {
    self = [super init];
    NSMutableArray *referencesArray = [NSMutableArray arrayWithCapacity:count];
    for (int index = 0; index < count; index++) {
        id object = objects[index];
        [referencesArray addObject:[MHSoftReference reference:object]];
    }
    NSArray *keysArray = [NSArray arrayWithObjects:keys count:count];
    _dictionary = [[NSMutableDictionary alloc] initWithObjects:referencesArray forKeys:keysArray];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(softReferencesUpdated) name:MHSoftReferenceLowMemoryWeakConversionComplete object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSUInteger)count {
    return self.dictionary.count;
}

- (id)objectForKey:(id)aKey {
    MHSoftReference *reference = self.dictionary[aKey];
    return reference.value;
}

- (NSEnumerator *)keyEnumerator {
    return self.dictionary.keyEnumerator;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    self.dictionary[aKey] = [MHSoftReference reference:anObject];
}

- (void)removeObjectForKey:(id)aKey {
    return [self.dictionary removeObjectForKey:aKey];
}

- (void)softReferencesUpdated {
    NSMutableArray *deadReferenceKey = [NSMutableArray array];
    for (id key in self.keyEnumerator) {
        MHSoftReference *reference = self.dictionary[key];
        if (!reference.value) {
            [deadReferenceKey addObject:key];
        }
    }
    [self.dictionary removeObjectsForKeys:deadReferenceKey];
}

@end