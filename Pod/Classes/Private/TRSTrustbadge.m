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

    id activeReviewCount = json[@"response"][@"data"][@"shop"][@"qualityIndicators"][@"reviewIndicator"][@"activeReviewCount"];
    _numberOfReviews = [(NSNumber *)activeReviewCount unsignedIntegerValue];

    id overallMark = json[@"response"][@"data"][@"shop"][@"qualityIndicators"][@"reviewIndicator"][@"overallMark"];
    _rating = (NSNumber *)overallMark;


    return self;
}

- (NSUInteger)numberOfReviews {
    return _numberOfReviews;
}

- (NSNumber *)rating {
    return _rating;
}

@end
