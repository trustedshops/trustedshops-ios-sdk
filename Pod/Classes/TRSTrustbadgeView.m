#import "TRSTrustbadgeView.h"
#import "TRSNetworkAgent+Trustbadge.h"
#import "TRSRatingView.h"
#import "TRSTrustbadge.h"


@interface TRSTrustbadgeView ()

@property (nonatomic, copy, readwrite) NSString *trustedShopsID;
@property (nonatomic, strong) NSNumberFormatter *decimalFormatter;
@property (nonatomic, strong) UIImage *sealImage;
@property (nonatomic, strong) TRSRatingView *ratingView;
@property (nonatomic, strong) UILabel *ratingLabel;
@property (nonatomic, strong) UILabel *reviewsLabel;
@property (nonatomic, strong) UIImageView *sealView;

@end

static CGFloat const TRSTrustbadgePadding = 10.0f;

@implementation TRSTrustbadgeView

#pragma mark - Initialization

- (instancetype)initWithTrustedShopsID:(NSString *)trustedShopsID {
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 56.0f)];
    if (!self) {
        return nil;
    }

    _trustedShopsID = [trustedShopsID copy];

    void (^success)(TRSTrustbadge *trustbadge) = ^(TRSTrustbadge *trustbadge) {
        self.ratingView = [[TRSRatingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 86.0f, 18.0f)
                                                                  rating:trustbadge.rating];

        self.ratingLabel = [self labelForRating:trustbadge.rating];
        self.reviewsLabel = [self labelForReviews:trustbadge.numberOfReviews];
        self.sealView = [[UIImageView alloc] initWithImage:self.sealImage];
    };

    void (^failure)(NSError *error) = ^(NSError *error) {

    };

    TRSNetworkAgent *agent = [TRSNetworkAgent sharedAgent];
    [agent getTrustbadgeForTrustedShopsID:_trustedShopsID
                                  success:success
                                  failure:failure];

    return self;
}

#pragma mark - UIView(UIViewHierarchy)

- (void)layoutSubviews {
    [self createConstraints];
    [super layoutSubviews];
}

#pragma mark - Helper

- (void)createConstraints {
    {   // Rating View Constraints
        [self.ratingView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.ratingView];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.ratingView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0f
                                                          constant:TRSTrustbadgePadding]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.ratingView
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeading
                                                        multiplier:1.0f
                                                          constant:TRSTrustbadgePadding]];
    }

    {   // Rating Label Constraints
        [self.ratingLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.ratingLabel];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.ratingLabel
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.ratingView
                                                         attribute:NSLayoutAttributeTrailing
                                                        multiplier:1.0f
                                                          constant:TRSTrustbadgePadding]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.ratingLabel
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.ratingView
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0f
                                                          constant:0.0f]];
    }

    {   // Reviews Label Constraints
        [self.reviewsLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.reviewsLabel];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.reviewsLabel
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0f
                                                          constant:TRSTrustbadgePadding]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.reviewsLabel
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.ratingView
                                                         attribute:NSLayoutAttributeLeading
                                                        multiplier:1.0f
                                                          constant:0.0f]];
    }

    {   // Seal View Constraints
        [self.sealView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.sealView];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.sealView
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:TRSTrustbadgePadding]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sealView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:0.0f]];
    }
}

- (NSNumberFormatter *)decimalFormatter {
    if (!_decimalFormatter) {
        NSNumberFormatter *decimalFormatter = [[NSNumberFormatter alloc] init];
        decimalFormatter.minimumIntegerDigits = 1;
        decimalFormatter.minimumFractionDigits = 2;
        decimalFormatter.maximumFractionDigits = 2;
        _decimalFormatter = decimalFormatter;
    }

    return _decimalFormatter;
}

- (UIImage *)sealImage {
    if (!_sealImage) {
        NSString *bundlePath = [[NSBundle bundleForClass:[self class]] bundlePath];
        NSBundle *bundle = [NSBundle bundleWithPath:[bundlePath stringByAppendingPathComponent:@"trustbadge.bundle"]];
        _sealImage = [UIImage imageWithContentsOfFile:[[bundle resourcePath] stringByAppendingPathComponent:@"iOS-SDK-Seal.png"]];
    }

    return _sealImage;
}

- (UILabel *)labelForRating:(NSNumber *)rating {
    UILabel *ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 18.0f)];
    ratingLabel.attributedText = [self ratingStringForRating:rating];
    return ratingLabel;
}

- (UILabel *)labelForReviews:(NSUInteger)numberOfReviews {
    UILabel *reviewsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 18.0f)];
    reviewsLabel.font = [UIFont fontWithName:@"Arial" size:14.0];
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] bundlePath];
    NSBundle *bundle = [NSBundle bundleWithPath:[bundlePath stringByAppendingPathComponent:@"trustbadge.bundle"]];
    reviewsLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"trustbadge.label.review %lu Reviews", @"trustbadge", bundle, nil), (unsigned long)numberOfReviews];
    return reviewsLabel;
}

- (NSAttributedString *)ratingStringForRating:(NSNumber *)rating {
    NSString *maxRatingString = [NSString stringWithFormat:@"/%@", [self.decimalFormatter stringFromNumber:@5.0]];
    NSString *ratingString = [NSString stringWithFormat:@"%@%@", [self.decimalFormatter stringFromNumber:rating], maxRatingString];

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
