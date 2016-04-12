//
//  TRSOrder.h
//  Pods
//
//  Created by Gero Herkenrath on 11/04/16.
//
//

#import <Foundation/Foundation.h>
@class TRSConsumer;

/**
 The state an order object can be in. These are preliminary and might change.
 Note that although the states are implemented as a bitmask, certain combinations will not be valid, e.g.
 `TRSOrderUnprocessed | TRSOrderProcessed`. A more thorough design might come in the future.
 */
typedef NS_OPTIONS(NSUInteger, TRSOrderState) {
	/** The state any newly created `TRSOrder` object is in before it has been validated or sent to the remote API. 
	 Mutually exclusive with `TRSOrderStateProcessing` and `TRSOrderStateProcessed`. */
	TRSOrderUnprocessed = (1 << 0),
	/** Usually the state after a `validateWithCompletionBlock:` has been called. This is also the state when
	 `finishWithCompletionBlock:` or `validateAndFinishWithCompletionBlock:` have been called on the object
	 but an error happens during these calls, i.e. the object was not yet in a state allowing successful 
	 processing or there was a problem contacting the remote API. Mutually exclusive with `TRSOrderStateUnprocessed`
	 and `TRSOrderStateProcessed`. */
	TRSOrderProcessing = (1 << 1),
	/** This state denotes some information about the data is missing or invalid. In the current implementation
	 this should never happen.*/
	TRSOrderIncompleteData = (1 << 2),
	/** The state after `finishWithCompletionBlock:` or `validateAndFinishWithCompletionBlock:` have been
	 called successfully. The remote API has been contacted and no further connections to it with this
	 object will be made. Usually that means you can safely release ownership of the object.
	 Mutually exclusive with `TRSOrderStateProcessing` and `TRSOrderStateUnprocessed`. */
	TRSOrderProcessed = (1 << 3),
	/** This denotes that the amount field in the order exceeds the usual value that the Trusted Shops guarantee 
	 covers. Since this value might vary over time or region, you should not rely on fixed numbers
	 but instead check for this state after `finishWithCompletionBlock:`, `validateAndFinishWithCompletionBlock:`,
	 or `validateWithCompletionBlock:` has been called. Mutually exclusive with `TRSOrderBillAboveThreshold`.*/
	TRSOrderBillBelowThreshold = (1 << 4),
	/** The counterpart to `TRSOrderBillBelowThreshold`. See there for further information. */
	TRSOrderBillAboveThreshold = (1 << 5)
};

/**
 Denotes whether the order is covered by the Trusted Shps guarantee. This does not only depend on `TRSOrderState`
 but also on the consumer's membership state. You should not rely on fixed numbers, but instead on this state flag
 after `finishWithCompletionBlock:`, `validateAndFinishWithCompletionBlock:`, or `validateWithCompletionBlock:` 
 has been called.
 */
typedef NS_ENUM(NSUInteger, TRSInsuranceState) {
	/** The state of insurance could not yet be determined since the remote API has not been contacted. */
	TRSUnknown,
	/** The order is not covered by the Trusted Shops guarantee/is not insured. */
	TRSNotInsured,
	/** The order is only partially covered by the Trsuted Shops guarantee/insurance, possibly because
	 it's amount lies over a certain threshold and the consumer is not a premium member.*/
	TRSPartiallyInsured,
	/** The order is fully insured. */
	TRSFullyInsured
};

/**
 This is a pure information type to let you know what the SDK will do on the next call of `finishWithCompletionBlock:`
 or `validateAndFinishWithCompletionBlock:` in case you want to prepare your UI in some way.
 To do so call `validateWithCompletionBlock:` on a fully instantiated `TRSOrder` object and check for its
 `nextActionFlag` property.
 */
typedef NS_ENUM(NSUInteger, TRSNextActionFlag) {
	/** The SDK will not display any UI elements in regards to this `TRSOrder` on subsequent
	 calls to `finishWithCompletionBlock:` or `validateAndFinishWithCompletionBlock:`. Usually this means
	 that one of these methods has been called before and no error occured. */
	TRSNoNextActions,
	/** This state is the default for a newly instantiated `TRSOrder` object. It denotes that the next
	 actions depend on first validating the object by calling `validateWithCompletionBlock:`.*/
	TRSValidationPending,
	/** This denotes the object will display a web view in a modal view to inform the user about his or her
	 Trusted Shops guarantee information.*/
	TRSShowWebViewInLightbox,
	/** This state is currently not used. */
	TRSShowExistingInsurance,
	/** This state is currently not used. */
	TRSRecommendUpgrageInWebView,
	/** This state is currently not used. */
	TRSShowUpgradeInComingEmail
};

/**
 `TRSOrder` is responsible to collect & send all data necessary to insure a purchase with the Trusted Shops guarantee.
 It will contact the remote API to put the transaction into our data base and check whether the consumer is already
 a member at Trusted Shops.
 Since this requires user interaction, the calls to do so will open a lightbox in the UI and display the needed
 information for the user & process necessary interaction in a webview.
 */
@interface TRSOrder : NSObject

@property (nonatomic, readonly, nonnull) NSString *tsID;
@property (nonatomic, readonly, nonnull) NSString *apiToken;

@property (nonatomic, readonly, nonnull) TRSConsumer *consumer;
@property (nonatomic, readonly, nonnull) NSString *ordernr;
@property (nonatomic, readonly, nonnull) NSNumber *amount;
/**
 The currency the order's payment is made in. 
 
 Valid strings for this must be from this array: <br />
 `@[@"EUR", @"USD", @"AUD", @"CAD", @"CHF", @"DKK", @"GBP", @"JPY", @"NZD", @"SEK", @"PLN", @"NOK", @"BGN",
 @"RON", @"RUB", @"TRY", @"CZK", @"HUF", @"HRK"]`
 */
@property (nonatomic, readonly, nonnull) NSString *curr;
/**
 The payment type for the order.
 
 Valid strings for this must be from this array: <br />
 `@[@"DIRECT_DEBIT", @"CASH_ON_PICKUP", @"CLICKANDBUY", @"FINANCING", @"GIROPAY", @"GOOGLE_CHECKOUT", @"CREDIT_CARD", 
 @"LEASING", @"MONEYBOOKERS", @"CASH_ON_DELIVERY", @"PAYBOX", @"PAYPAL", @"INVOICE", @"CHEQUE", @"SHOP_CARD", 
 @"DIRECT_E_BANKING", @"T_PAY", @"PREPAYMENT", @"AMAZON_PAYMENTS"]`
 */
@property (nonatomic, readonly, nonnull) NSString *paymentType;

@property (nonatomic, strong, nullable) NSDate *deliveryDate;
// last one will be fleshed out later...
@property (nonatomic, strong, nullable) NSDictionary *tsCheckoutProductItems; // for now. will probably be changed to custom class

@property (nonatomic, readonly) TRSOrderState orderState;
@property (nonatomic, readonly) TRSInsuranceState insuranceState;
@property (nonatomic, readonly) TRSNextActionFlag nextActionFlag;

/** @name Creating a TRSOrder instance. */

/**
 The designated initializer.
 
 All method arguments except the delivery date are mandatory, otherwise the method returns nil.
 
 @param trustedShopsID Your Trusted Shops ID.
 @param apiToken The token to authenticate your app for the (remote) API at Trusted Shops. Currently can be any `NSString`.
 @param email The email your customer used to make the purchase.
 @param orderNo A string uniquely representing the order that was made.
 @param amount The actual value of the purchase. Typically a float or double greater than 0 and with 2 digits after the decimal point.
 @param currency A string denoting the purchase the transaction was made in, e.g. `@"EUR"`.
 @param paymentType A string denoting the payment type, e.g. `@"OXIDPAYADVANCE"`.
 @param estDeliveryDate An `NSDate` object holding your estimate for the date the purchased product will arrive at the
 customer. Should lie in the future and can be `nil`.
 */
- (nullable instancetype)initWithTrustedShopsID:(nonnull NSString *)trustedShopsID
									   apiToken:(nonnull NSString *)apiToken
										  email:(nonnull NSString *)email
										ordernr:(nonnull NSString *)orderNo
										 amount:(nonnull NSNumber *)amount
										   curr:(nonnull NSString *)currency
									paymentType:(nonnull NSString *)paymentType
								   deliveryDate:(nullable NSDate *)estDeliveryDate NS_DESIGNATED_INITIALIZER;

+ (nullable instancetype)TRSOrderWithTrustedShopsID:(nonnull NSString *)trustedShopsID
										   apiToken:(nonnull NSString *)apiToken
											  email:(nonnull NSString *)email
											ordernr:(nonnull NSString *)orderNo
											 amount:(nonnull NSNumber *)amount
											   curr:(nonnull NSString *)currency
										paymentType:(nonnull NSString *)paymentType
									   deliveryDate:(nullable NSDate *)estDeliveryDate;

- (void)validateWithCompletionBlock:(nullable void (^)(NSError *_Nullable error))answer;
- (void)finishWithCompletionBlock:(nullable void (^)(NSError *_Nullable error))failure;
- (void)validateAndFinishWithCompletionBlock:(nullable void (^)(NSError *_Nullable error))onCompletion;

@end
