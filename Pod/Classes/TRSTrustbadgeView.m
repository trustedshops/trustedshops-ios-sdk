#import "TRSTrustbadgeView.h"
#import "TRSErrors.h"
#import "TRSNetworkAgent+Trustbadge.h"
#import "TRSRatingView.h"
#import "TRSTrustbadge.h"
#import "UIColor+TRSColors.h"


@interface TRSTrustbadgeView ()

@property (nonatomic, copy, readwrite) NSString *trustedShopsID;
@property (nonatomic, strong) NSNumberFormatter *decimalFormatter;
@property (nonatomic, strong) UIView *canvasView;
@property (nonatomic, strong) UIImageView *triangleView;
@property (nonatomic, strong) UIImage *triangleImage;
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
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 64.0f)];
    if (!self) {
        return nil;
    }

    if (!trustedShopsID) {
        return nil;
    }
    _trustedShopsID = [trustedShopsID copy];

    self.backgroundColor = [UIColor trs_trustbadgeBorderColor];
    self.canvasView = [[UIView alloc ] initWithFrame:CGRectZero];
    self.canvasView.backgroundColor = [UIColor whiteColor];
    self.triangleView = [[UIImageView alloc] initWithImage:self.triangleImage];
    self.sealView = [[UIImageView alloc] initWithImage:self.sealImage];
    [self addEmptyTrustbadgeViews];

    void (^success)(TRSTrustbadge *trustbadge) = ^(TRSTrustbadge *trustbadge) {
        [self removeTrustbadgeViews];
        [self addTrustbadgeViewWithTrustbadge:trustbadge];
        [self createConstraints];
    };

    void (^failure)(NSError *error) = ^(NSError *error) {
        if (![error.domain isEqualToString:TRSErrorDomain]) {
            return;
        }

        switch (error.code) {
            case TRSErrorDomainTrustbadgeInvalidTSID:
                NSLog(@"[trustbadge] The provided TSID is not correct.");
                break;

            case TRSErrorDomainTrustbadgeTSIDNotFound:
                NSLog(@"[trustbadge] The provided TSID could not be found.");
                break;

            case TRSErrorDomainTrustbadgeInvalidData:
                NSLog(@"[trustbadge] The received data is corrupt.");
                break;

            case TRSErrorDomainTrustbadgeUnknownError:
            default:
                NSLog(@"[trustbadge] An unkown error occured.");
                break;
        }
    };

    [[TRSNetworkAgent sharedAgent] getTrustbadgeForTrustedShopsID:_trustedShopsID
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

- (void)addEmptyTrustbadgeViews {
    [self addTrustbadgeViewWithTrustbadge:nil];
}

- (void)addTrustbadgeViewWithTrustbadge:(TRSTrustbadge *)trustbadge {
    NSNumber *rating;
    NSUInteger numberOfReviews = 0;
    if (!trustbadge) {
        rating = @0.0f;
    } else {
        rating = trustbadge.rating;
        numberOfReviews = trustbadge.numberOfReviews;
    }

    self.ratingView = [[TRSRatingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 86.0f, 18.0f)
                                                    rating:rating];
    self.ratingLabel = [self labelForRating:rating];
    self.reviewsLabel = [self labelForReviews:numberOfReviews];
}

- (void)removeTrustbadgeViews {
    [self.ratingView removeFromSuperview];
    self.ratingView = nil;

    [self.ratingLabel removeFromSuperview];
    self.ratingLabel = nil;

    [self.reviewsLabel removeFromSuperview];
    self.reviewsLabel = nil;
}

- (void)createConstraints {
    {   // Canvas Constraints
        [self.canvasView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.canvasView];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.canvasView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0f
                                                          constant:0.0f]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.canvasView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0f
                                                          constant:56.0f]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.canvasView
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeading
                                                        multiplier:1.0f
                                                          constant:0.0f]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.canvasView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0f
                                                          constant:0.0f]];
    }

    {   // Rating View Constraints
        [self.ratingView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.canvasView addSubview:self.ratingView];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.ratingView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.canvasView
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0f
                                                          constant:TRSTrustbadgePadding]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.ratingView
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.canvasView
                                                         attribute:NSLayoutAttributeLeading
                                                        multiplier:1.0f
                                                          constant:TRSTrustbadgePadding]];
    }

    {   // Rating Label Constraints
        [self.ratingLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.canvasView addSubview:self.ratingLabel];

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
        [self.canvasView addSubview:self.reviewsLabel];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.canvasView
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
        [self.canvasView addSubview:self.sealView];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.canvasView
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.sealView
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:TRSTrustbadgePadding]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sealView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.canvasView
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:0.0f]];
    }

    {   // Triangle View Constraints
        [self.triangleView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.canvasView addSubview:self.triangleView];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.canvasView
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.triangleView
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:TRSTrustbadgePadding]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.triangleView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.canvasView
                                                         attribute:NSLayoutAttributeBottom
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

- (UIImage *)triangleImage {
    if (!_triangleImage) {
        NSString *bundlePath = [[NSBundle bundleForClass:[self class]] bundlePath];
        NSBundle *bundle = [NSBundle bundleWithPath:[bundlePath stringByAppendingPathComponent:@"trustbadge.bundle"]];
        _triangleImage = [UIImage imageWithContentsOfFile:[[bundle resourcePath] stringByAppendingPathComponent:@"iOS-SDK-Triangle.png"]];
    }

    return _triangleImage;
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
