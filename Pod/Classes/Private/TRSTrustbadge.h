#import <Foundation/Foundation.h>

@class TRSShop;

/**
 *  @c TRSTrustbadge is the underlying model of a Trustbadge.
 */
@interface TRSTrustbadge : NSObject

/**
 * @name Initialization
 */

/**
 *  Initialize a @c TRSTrustbadge with the provided data.
 *
 *  @param data The data provided by the API as JSON
 *
 *  @return An initialized object if the provided data object was valid; @c nil otherwise.
 */
- (instancetype)initWithData:(NSData *)data;

- (void)showTrustcard;

@property (nonatomic, strong) TRSShop *shop;
@property (nonatomic, weak) UIColor *customColor;

@end
