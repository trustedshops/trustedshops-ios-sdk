//
//  TRSStarsView.h
//  Pods
//
//  Created by Gero Herkenrath on 13/06/16.
//  (Class was formerly TRSRatingView)
//

#import <UIKit/UIKit.h>

/**
 A constant defining the number of stars in a `TRSStarsView`.
 */
FOUNDATION_EXPORT NSUInteger const kTRSStarsViewNumberOfStars;

/**
 The `TRSStarsView` class is a subclass of `UIView`. 
 
 It simply draws five stars in a horizontal row that can be filled to an extent.
 For that it has a rating, a value between 1 and 5. If, for example, the rating is 4.5 then the first (left) four stars
 are filled with `activeStarColor`, and the last star's left half is also `activeStarColor`, while its right half
 is `inactiveStarColor`.
 
 Note that the view's frame rectangel always has an aspect ratio of 5 to 1 and that it has a minimum size of
 50.0 times 10.0 points on screen.
 */
@interface TRSStarsView : UIView

/** The rating given to the view. Lies between 1 and 5. */
@property (nonatomic, readonly) NSNumber *rating;

/** The color used to denote active (parts of) stars. Defaults to a shade of yellow (ananas). */
@property (nonatomic, strong) UIColor *activeStarColor;
/** The color used to denote inactive (parts of) stars. Defaults to a dark grey color.*/
@property (nonatomic, strong) UIColor *inactiveStarColor;

/**
 The designated initializer.
 
 If you specify `nil` for the rating value, the stars will be drawn completely filled with `activeStarColor`, i.e.
 the rating property defaults to 5.
 @param frame the view's frame.
 @param rating the view's rating.
 */
- (instancetype)initWithFrame:(CGRect)frame rating:(NSNumber *)rating NS_DESIGNATED_INITIALIZER;
/**
 Inits the view with a `CGRectZero` rect.
 
 Note that although the frame rectange is `CGRectZero` right after initialization, the view will always be drawn
 with its minimum size of 50.0 times 10.0.
 @param rating the view's rating.
 */
- (instancetype)initWithRating:(NSNumber *)rating;

/**
 A convenience initializer to instantiate a `TRSStarsView` with a given rating.
 
 This simply calls `initWithRating:` on a new allocated `TRSStarsView` object.
 @param rating the view's rating.
 */
+ (instancetype)starsWithRating:(NSNumber *)rating;

@end
