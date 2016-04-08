#import <UIKit/UIKit.h>

/**
 *  `TRSStarView` is a subclass of `UIView` for creating five-point stars.
 */
@interface TRSStarView : UIView

/**
 *  @name Creating a Star View
 */

/**
 *  Creates and returns a `TRSStarView` view with 100% fill.
 *
 *  @param size The size of a star. If `width` and `height` are not equal, than the smaller value is used instead.
 *
 *  @return A `TRSStartView` view
 */
+ (instancetype)filledStarWithSize:(CGSize)size;

/**
 *  Creates and returns a `TRSStarView` view without a fill.
 *
 *  @param size The size of a star. If `width` and `height` are not equal, than the smaller value is used instead.
 *
 *  @return A `TRSStartView` view
 */
+ (instancetype)emptyStarWithSize:(CGSize)size;

/**
 *  @name Initializing a Star View
 */

/**
 *  Initialize a `TRSStarView` view with the given `size` and how much a star should be filled. This method is the designated initializer.
 *
 *  @param size          The size of a star. If `width` and `height` are not equal, than the smaller value is used instead.
 *  @param percentFilled The filled valued of the star. The number must be in {@literal [}0.0, 1.0{@literal ]}. 
 *	If `percentFilled` is `nil` use 1.0 instead.
 *
 *  @return A `TRSStartView` view
 */
- (instancetype)initWithSize:(CGSize)size percentFilled:(NSNumber *)percentFilled;

@end
