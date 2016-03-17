#import "TRSTrustbadge.h"
#import "TRSShop.h"
#import "TRSTrustcard.h"


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
	// lazy load the trustcard class
	if (!self.trustcard) {
		self.trustcard = [[TRSTrustcard alloc] init];
	}
	
	[self.trustcard showInLightboxForTrustbadge:self];
}

@end
