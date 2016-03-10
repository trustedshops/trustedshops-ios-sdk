#import "TRSTrustbadge.h"


@interface TRSTrustbadge ()

@property (nonatomic, readwrite) NSUInteger numberOfReviews;
@property (nonatomic, readwrite, strong) NSNumber *rating;

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

	// TODO: Rework this so it is equal to Android API
	// Note: This json structure is fitting for the older SDK which used a different api.
	// The new version has a different json and works different. Try to not break old stuff, but we can
	// live if that results in "no reviews" displayed or the like.
	// LEGACY CODE BEGINS HERE
    id activeReviewCount = json[@"response"][@"data"][@"shop"][@"qualityIndicators"][@"reviewIndicator"][@"activeReviewCount"];
    _numberOfReviews = [(NSNumber *)activeReviewCount unsignedIntegerValue];

    id overallMark = json[@"response"][@"data"][@"shop"][@"qualityIndicators"][@"reviewIndicator"][@"overallMark"];
    _rating = (NSNumber *)overallMark;
	// LEGACY CODE ENDS HERE
	// I simply return this for now, if the legacy stuff had a result (if not, I assume a newer api and keep on working
	if (activeReviewCount && overallMark) {
		return self;
	}
	
	// starting here, I assume the newer api and construct a shop object and so on

    return self;
}

- (NSUInteger)numberOfReviews {
    return _numberOfReviews;
}

- (NSNumber *)rating {
    return _rating;
}

@end
