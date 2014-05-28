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

@property (nonatomic, readonly) Class classUnderTest;

@end