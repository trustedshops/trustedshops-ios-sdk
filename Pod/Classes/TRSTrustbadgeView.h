#import <UIKit/UIKit.h>

/**
 *  `TRSTrustbadgeView` is a subclass of `UIView` for creating a Trustbadge.
 */
@interface TRSTrustbadgeView : UIView

/**
 *  @name Creating a Trustbadge View
 */

/**
 *  Creates and initializes a Trustbadge view.
 *
 *  @param trustedShopsID The Trusted Shops ID for the desired Trustbadge.
 *
 *  @return A fully initialized view object for the provided Trusted Shops ID.
 */
- (instancetype)initWithTrustedShopsID:(NSString *)trustedShopsID;

/**
 *  Trusted Shops ID provided during the initialization.
 */
@property (nonatomic, copy, readonly) NSString *trustedShopsID;

@end
