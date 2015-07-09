#import <UIKit/UIKit.h>

/**
 *  `TRSRatingView` is a subclass of `UIView` for creating a view with a star-rating in the range [0.0, 5.0]. The stars will be centered horizontally and vertically in the view.
 */
@interface TRSRatingView : UIView

/**
 *  Initialize an `TRSRatingView` object with the specified frame and rating.
 *
 *  @param frame  The frame for the stars.
 *  @param rating The rating in the range [0.0, 5.0].
 *
 *  @return An initialized `TRSRatingView` object.
 */
- (instancetype)initWithFrame:(CGRect)frame rating:(NSNumber *)rating;

@end
