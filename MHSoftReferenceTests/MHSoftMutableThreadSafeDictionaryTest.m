#import <XCTest/XCTest.h>
#import "MHSoftMutableDictionaryTest.h"
#import "MHSoftMutableThreadSafeDictionary.h"

@interface MHSoftMutableThreadSafeDictionaryTest : MHSoftMutableDictionaryTest

@end

@implementation MHSoftMutableThreadSafeDictionaryTest

- (Class)classUnderTest {
    return MHSoftMutableThreadSafeDictionary.class;
}

@end
