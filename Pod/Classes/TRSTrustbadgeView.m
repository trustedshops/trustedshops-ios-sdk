#import "TRSTrustbadgeView.h"
#import "TRSNetworkAgent+Trustbadge.h"
#import "TRSRatingView.h"
#import "TRSTrustbadge.h"


@interface TRSTrustbadgeView ()

@property (nonatomic, copy, readwrite) NSString *trustedShopsID;
@property (nonatomic, strong) NSNumberFormatter *decimalFormatter;

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

        UILabel *ratingLabel = [self labelForRating:trustbadge.rating];

        [self addSubview:ratingView];
        [self addSubview:ratingLabel];
    };

    void (^failure)(NSError *error) = ^(NSError *error) {

    };

    TRSNetworkAgent *agent = [TRSNetworkAgent sharedAgent];
    [agent getTrustbadgeForTrustedShopsID:_trustedShopsID
                                  success:success
                                  failure:failure];

    return self;
}

- (NSNumberFormatter *)decimalFormatter {
    if (!_decimalFormatter) {
        NSNumberFormatter *decimalFormatter = [[NSNumberFormatter alloc] init];
        decimalFormatter.minimumFractionDigits = 2;
        decimalFormatter.maximumFractionDigits = 2;
        _decimalFormatter = decimalFormatter;
    }

    return _decimalFormatter;
}

- (UILabel *)labelForRating:(NSNumber *)rating {
    UILabel *ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 18.0f)];
    ratingLabel.attributedText = [self ratingStringForRating:rating];
    return ratingLabel;
}

- (NSAttributedString *)ratingStringForRating:(NSNumber *)rating {
    NSString *maxRatingString = [NSString stringWithFormat:@"/%@", [self.decimalFormatter stringFromNumber:@5.0]];
    NSString *ratingString = [NSString stringWithFormat:@"%@%@", rating, maxRatingString];

    UIFont *normalFont = [UIFont fontWithName:@"Arial" size:14.0];
    NSDictionary *attributes = @{ NSFontAttributeName : normalFont };
    NSMutableAttributedString *attributedRatingString = [[NSMutableAttributedString alloc] initWithString:ratingString
                                                                                               attributes:attributes];

    UIFont *smallFont = [UIFont fontWithName:@"Arial" size:12.0];
    UIColor *grayColor = [UIColor grayColor];
    NSRange range = [ratingString rangeOfString:maxRatingString];

    [attributedRatingString addAttribute:NSFontAttributeName
                                   value:smallFont
                                   range:range];

    [attributedRatingString addAttribute:NSForegroundColorAttributeName
                                   value:grayColor
                                   range:range];

    return [attributedRatingString copy];
}

@end
