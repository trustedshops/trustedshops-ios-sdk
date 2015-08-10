#import "TRSTrustbadgeView.h"

@interface TRSTrustbadgeView ()

@property (nonatomic, copy, readwrite) NSString *trustedShopsID;

@end

@implementation TRSTrustbadgeView

- (instancetype)initWithTrustedShopsID:(NSString *)trustedShopsID {
    self = [super initWithFrame:CGRectZero];
    if (!self) {
        return nil;
    }

    _trustedShopsID = [trustedShopsID copy];

    return self;
}

@end
