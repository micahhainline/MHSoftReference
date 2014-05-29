#import "MHSoftMutableThreadSafeDictionary.h"
#import "MHSoftReference.h"
#import "MHSoftReferencePrivateConstants.h"

@interface MHSoftMutableThreadSafeDictionary ()

@property (nonatomic, readonly) NSMutableDictionary *dictionary;
@property (nonatomic, readonly) dispatch_queue_t isolationQueue;

@end

@implementation MHSoftMutableThreadSafeDictionary

- (id)init {
    return [self initWithObjectsAndKeys:nil];
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    self = [super init];
    _dictionary = [[NSMutableDictionary alloc] initWithCapacity:numItems];
    [self commonInitialization];
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
    [self commonInitialization];
    return self;
}

- (void)commonInitialization {
    _isolationQueue = dispatch_queue_create([[[NSUUID UUID] UUIDString] UTF8String], DISPATCH_QUEUE_CONCURRENT);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(softReferencesUpdated) name:MHSoftReferenceLowMemoryWeakConversionComplete object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSUInteger)count {
    __block NSUInteger count;
    dispatch_sync(self.isolationQueue, ^{
        count = self.dictionary.count;
    });
    return count;
}

- (id)objectForKey:(id)aKey {
    __block id object = nil;
    dispatch_sync(self.isolationQueue, ^{
        MHSoftReference *reference = self.dictionary[aKey];
        object = reference.value;
    });
    return object;
}

- (NSEnumerator *)keyEnumerator {
    __block NSEnumerator *keyEnumerator = nil;
    dispatch_sync(self.isolationQueue, ^{
        keyEnumerator = self.dictionary.keyEnumerator;
    });
    return keyEnumerator;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    NSLog(@"key: %@ obj: %p", aKey, anObject);
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[aKey] = anObject;
    dispatch_barrier_async(self.isolationQueue, ^{
        self.dictionary[aKey] = [MHSoftReference reference:anObject];
    });
}

- (void)removeObjectForKey:(id)aKey {
    return [self.dictionary removeObjectForKey:aKey];
}

- (void)softReferencesUpdated {
    NSEnumerator *keyEnumerator = self.keyEnumerator;
    dispatch_barrier_async(self.isolationQueue, ^{
        NSMutableArray *deadReferenceKey = [NSMutableArray array];
        for (id key in keyEnumerator) {
            MHSoftReference *reference = self.dictionary[key];
            if (!reference.value) {
                [deadReferenceKey addObject:key];
            }
        }
        [self.dictionary removeObjectsForKeys:deadReferenceKey];
    });
}

@end
