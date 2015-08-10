#import "TRSTrustbadgeView.h"
#import "TRSNetworkAgent+Trustbadge.h"
#import "TRSRatingView.h"
#import "TRSTrustbadge.h"


@interface TRSTrustbadgeView ()

@property (nonatomic, copy, readwrite) NSString *trustedShopsID;

@end

@implementation TRSTrustbadgeView

- (instancetype)initWithTrustedShopsID:(NSString *)trustedShopsID {
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 36.0f)];
    if (!self) {
        return nil;
    }

    _trustedShopsID = [trustedShopsID copy];

    void (^success)(TRSTrustbadge *trustbadge) = ^(TRSTrustbadge *trustbadge) {
        TRSRatingView *ratingView = [[TRSRatingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 86.0f, 18.0f)
                                                                  rating:trustbadge.rating];

        [self addSubview:ratingView];
    };

    void (^failure)(NSError *error) = ^(NSError *error) {

    };

    TRSNetworkAgent *agent = [TRSNetworkAgent sharedAgent];
    [agent getTrustbadgeForTrustedShopsID:_trustedShopsID
                                  success:success
                                  failure:failure];

    return self;
}

@end
