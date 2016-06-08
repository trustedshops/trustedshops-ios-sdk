#import <Foundation/Foundation.h>

@interface TRSTrustbadgeSDKPrivate : NSObject

NSBundle *TRSTrustbadgeBundle(void);

@end

// The following macro mimics the default NSLocalizedString macro. To use genstrings with it
// rely on the -s parameter: Run `genstrings -s TRSLocalizedString -o <outputdir> <file(s)>
#define TRSLocalizedString(key, comment) \
		[TRSTrustbadgeBundle() localizedStringForKey:(key) value:@"" table:nil]
