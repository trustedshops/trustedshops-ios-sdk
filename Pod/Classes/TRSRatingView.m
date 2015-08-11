#import "TRSRatingView.h"

#import "NSNumber+TRSRating.h"
#import "TRSStarView.h"

static NSUInteger const numberOfStars = 5;

@interface TRSRatingView ()

@property (nonatomic, strong) NSNumber *integralOfRating;
@property (nonatomic, strong) NSNumber *fractionalOfRating;
@property (nonatomic, strong) NSArray *starViews;

@end


@implementation TRSRatingView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame rating:(NSNumber *)rating {
    self = [super initWithFrame:frame];

    if (!self) {
        return nil;
    }

    _integralOfRating = [rating trs_integralPart];
    _fractionalOfRating = [rating trs_fractionalPart];

    [self setup];

    return self;
}

#pragma mark - UIView(UIViewHierarchy)

- (void)layoutSubviews {
    [self createConstraints];
    [super layoutSubviews];
}

#pragma mark - UIView (UIConstraintBasedLayoutLayering)

- (CGSize)intrinsicContentSize {
    return self.bounds.size;
}

#pragma mark - Helper

- (void)setup {
    [self createStars];
    [self createConstraints];
}

- (void)createStars {
    NSMutableArray *starViews = [NSMutableArray arrayWithCapacity:numberOfStars];

    CGFloat length = MIN(self.bounds.size.width / numberOfStars, self.bounds.size.height);
    CGSize size = CGSizeMake(length, length);

    BOOL addedFractionalStar = NO;
    for (NSUInteger idx = 0; idx < numberOfStars; idx++) {
        UIView *starView;

        if (idx < [self.integralOfRating unsignedIntegerValue]) {
            starView = [[TRSStarView alloc] initWithSize:size percentFilled:@1];
        } else if ([self.fractionalOfRating floatValue] > 0.0f && !addedFractionalStar) {
            starView = [[TRSStarView alloc] initWithSize:size percentFilled:self.fractionalOfRating];
            addedFractionalStar = YES;
        } else {
            starView = [[TRSStarView alloc] initWithSize:size percentFilled:@0];
        }

        [starViews addObject:starView];
    }

    self.starViews = [starViews copy];
}

- (void)createConstraints {
    [self.starViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {

        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:view];

        if (idx > 0) {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.starViews[idx - 1]
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1.0f
                                                              constant:0.0f]];
        }

        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:0.0f]];
    }];

    NSUInteger centerIndex = (NSUInteger)(ceilf((float)numberOfStars / 2.0f) - 1);
    UIView *centerStar = self.starViews[centerIndex];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:centerStar
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
}

@end
