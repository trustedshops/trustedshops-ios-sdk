#import <Foundation/Foundation.h>

@class TRSShop;

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

- (void)showTrustcardWithPresentingViewController:(UIViewController *)presenter;

@property (nonatomic, strong) TRSShop *shop;
@property (nonatomic, weak) UIColor *customColor;
@property (nonatomic, assign) BOOL debugMode;

@end
