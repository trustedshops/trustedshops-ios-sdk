#import "TRSTrustbadge.h"
#import "TRSShop.h"
#import "TRSTrustcard.h"
#import "TRSTrustbadgeSDKPrivate.h"


@interface TRSTrustbadge ()

@property (nonatomic, strong) TRSTrustcard *trustcard;

@end

@implementation TRSTrustbadge

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (!self) {
        return nil;
    }

    if (!data) {
        return nil;
    }

    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&error];
    if (!json) {
        // inspect error;
        return nil;
    }

	self.shop = [[TRSShop alloc] initWithDictionary:json[@"response"][@"data"][@"shop"]];
    return self;
}

- (void)showTrustcard {
	if (!self.trustcard) { // init the VC displaying the card. it will figure everything out
		self.trustcard = [[TRSTrustcard alloc] initWithNibName:@"Trustcard" bundle:TRSTrustbadgeBundle()];
	}
	
	// Test: This path won't be the final one. Note we only supply the folder where the trustinfos.html file is located
	self.trustcard.remoteCertLocationFolder = @"https://widgets.trustedshops.com/sdktest";
	
	// tell it to display the data (the trustbadge is a weak property, so we're fine)
	[self.trustcard showInLightboxForTrustbadge:self];
}

@end
