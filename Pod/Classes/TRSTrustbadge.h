#import <Foundation/Foundation.h>

/**
 *  `TRSTrustbadge` is the underlying model of a Trustbadge.
 */
@interface TRSTrustbadge : NSObject

/**
 * @name Initialization
 */

/**
 *  Initialize a `TRSTrustbadge` with the provided data.
 *
 *  @param data The data provided by the API as JSON
 *
 *  @return An initialized object if the provided data object was valid; `nil` otherwise.
 */
- (instancetype)initWithData:(NSData *)data;

/**
 *  The number of reviews for this Trustbadge.
 */
@property (nonatomic, readonly) NSUInteger numberOfReviews;

/**
 *  The rating for this Trustbadge.
 */
@property (nonatomic, readonly, strong) NSNumber *rating;

@end
