#import <Foundation/Foundation.h>

/**
 `NSNumber+TRSRating` is a category for `NSNumber` for creating `NSNumber` objects from the sender. It creates 'NSNumber' objects with integral and fractional parts.
 */
@interface NSNumber (TRSRating)

/**
 Create an NSNumber object with the integral part of the receiver.

 @return A newly created `NSNumber` object.
 */
- (NSNumber *)trs_integralPart;

/**
 Create an NSNumber object with the fractional part of the receiver.

 @return A newly created `NSNumber` object.
 */
- (NSNumber *)trs_fractionalPart;

@end
