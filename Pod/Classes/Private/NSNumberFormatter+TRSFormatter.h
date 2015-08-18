#import <Foundation/Foundation.h>

@interface NSNumberFormatter (TRSFormatter)

/**
 *  A number formatter for the Trustbadge. The integer part of the number will be shown with one digit and the fraction part will be shown with two integer digits.
 *
 *  @return Fully initialized `NSNumberFormatter` object.
 */
+ (NSNumberFormatter *)trs_trustbadgeRatingFormatter;

@end
