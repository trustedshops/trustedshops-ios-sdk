//
//  TRSStarsView.h
//  Pods
//
//  Created by Gero Herkenrath on 13/06/16.
//  (Class was formerly TRSRatingView)
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSUInteger const kTRSStarsViewNumberOfStars;

@interface TRSStarsView : UIView

@property (nonatomic, readonly) NSNumber *rating;

@property (nonatomic, strong) UIColor *activeStarColor;
@property (nonatomic, strong) UIColor *inactiveStarColor;

- (instancetype)initWithFrame:(CGRect)frame rating:(NSNumber *)rating NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithRating:(NSNumber *)rating;

+ (instancetype)starsWithRating:(NSNumber *)rating;

@end
