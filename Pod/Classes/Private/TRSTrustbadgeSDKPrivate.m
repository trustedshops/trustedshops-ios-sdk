#import "TRSTrustbadgeSDKPrivate.h"

@implementation TRSTrustbadgeSDKPrivate

NSBundle *TRSTrustbadgeBundle(void) {
    static NSBundle *bundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle bundleForClass:[TRSTrustbadgeSDKPrivate class]] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"TrustbadgeResources.bundle"];
        bundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return bundle;
}

@end
