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
	 `finishWithCompletionBlock:` has been called on the object
	 but an error happens during these calls, i.e. the object was not yet in a state allowing successful 
	 processing or there was a problem contacting the remote API. Mutually exclusive with `TRSOrderStateUnprocessed`
	 and `TRSOrderStateProcessed`. */
	TRSOrderProcessing = (1 << 1),
	/** This state denotes some information about the data is missing or invalid. In the current implementation
	 this should never happen.*/
	TRSOrderIncompleteData = (1 << 2),
	/** The state after `finishWithCompletionBlock:` has been
	 called successfully. The remote API has been contacted and no further connections to it with this
	 object will be made. Usually that means you can safely release ownership of the object.
	 Mutually exclusive with `TRSOrderStateProcessing` and `TRSOrderStateUnprocessed`. */
	TRSOrderProcessed = (1 << 3),
	/** This denotes that the amount field in the order exceeds the usual value that the Trusted Shops guarantee 
	 covers. Since this value might vary over time or region, you should not rely on fixed numbers
	 but instead check for this state after `finishWithCompletionBlock:`
	 or `validateWithCompletionBlock:` has been called. Mutually exclusive with `TRSOrderBillAboveThreshold`.*/
	TRSOrderBillBelowThreshold = (1 << 4),
	/** The counterpart to `TRSOrderBillBelowThreshold`. See there for further information. */
	TRSOrderBillAboveThreshold = (1 << 5)
};

/**
 Denotes whether the order is covered by the Trusted Shps guarantee. This does not only depend on `TRSOrderState`
 but also on the consumer's membership state. You should not rely on fixed numbers, but instead on this state flag
 after `finishWithCompletionBlock:` or `validateWithCompletionBlock:`
 has been called.
 */
typedef NS_ENUM(NSUInteger, TRSInsuranceState) {
	/** The state of insurance could not yet be determined since the remote API has not been contacted. */
	TRSInsuranceStateUnknown = 1,
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
	 calls to `finishWithCompletionBlock:`. Usually this means
	 that one of these methods has been called before and no error occured. */
	TRSNoNextActions = 1,
	/** This state is the default for a newly instantiated `TRSOrder` object. It denotes that the next
	 actions depend on first validating the object by calling `validateWithCompletionBlock:`.*/
	TRSValidationPending,
	/** This denotes the object will display a web view in a modal view to inform the user about his or her
	 Trusted Shops guarantee information.*/
	TRSShowWebViewInLightbox,
	/** This state is currently not used. */
	TRSShowExistingInsurance,
	/** This state is currently not used. */
	TRSRecommendUpgradeInWebView,
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

/**
 The Trusted Shops ID associated with your shop.
 */
@property (nonatomic, readonly, nonnull) NSString *tsID;
/**
 The client token you get from Trusted Shops for verifying your app is allowed to access the API. Currently not used!
 */
@property (nonatomic, readonly, nonnull) NSString *apiToken;

/**
 The `TRSConsumer` object that was created to represent your customer in regards to Trusted Shop.
 */
@property (nonatomic, readonly, nonnull) TRSConsumer *consumer;
/**
 The order number you provide to identify the transaction.
 */
@property (nonatomic, readonly, nonnull) NSString *ordernr;
/**
 The amount of money the entire purchase is worth, i.e. the due payment.
 */
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

/**
 The estimated delivery date the order should arrive at the consumer. 
 
 This is an optional field you may set after the `TRSOrder` object has been initialized.
 */
@property (nonatomic, strong, nullable) NSDate *deliveryDate;
// last one will be fleshed out later...
/**
 A list of all the products in this order.
 */
@property (nonatomic, strong, nullable) NSDictionary *tsCheckoutProductItems; // for now. will probably be changed to custom class

/**
 The state the order is currently in, as related to the Trusted Shops remote API.
 
 This is a bitmask as defined in the `TRSOrderState` constants, see there for a detailed description of states.
 */
@property (nonatomic, readonly) TRSOrderState orderState;
/**
 The state of the insurance for the consumer's purchase/this order.
 
 Usually you don't need to care about this, since it's part of the relationship between Trusted Shops and the 
 consumer without any relevance for your business.
 */
@property (nonatomic, readonly) TRSInsuranceState insuranceState;
/**
 A flag informing you about potential UI changes that might occur with the next call of `finishWithCompletionBlock:`.
 
 This property is only useful to you right after you called `validateWithCompletionBlock:`, before that the object
 cannot deduce what might be shown. At the moment this is less relevant, because the UI changes are usually
 a displayed webview, but in future versions we might provide you with more detailed information.
 */
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
 @param paymentType A string denoting the payment type, e.g. `@"CREDIT_CARD"`.
 @param estDeliveryDate An `NSDate` object holding your estimate for the date the purchased product will arrive at the
 customer. Should lie in the future and can be `nil`.
 @see curr
 @see paymentType
 */
- (nullable instancetype)initWithTrustedShopsID:(nonnull NSString *)trustedShopsID
									   apiToken:(nonnull NSString *)apiToken
										  email:(nonnull NSString *)email
										ordernr:(nonnull NSString *)orderNo
										 amount:(nonnull NSNumber *)amount
										   curr:(nonnull NSString *)currency
									paymentType:(nonnull NSString *)paymentType
								   deliveryDate:(nullable NSDate *)estDeliveryDate NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init __attribute__((unavailable("You cannot create an instance through init - please use initWithTrustedShopsID:apiToken:email:ordernr:amount:curr:paymentType:deliveryDate:")));

/**
 A convenience method for creating a `TRSOrder` object.
 
 This method calls the designated initializer.
 All method arguments except the delivery date are mandatory, otherwise the method returns nil.
 
 @param trustedShopsID Your Trusted Shops ID.
 @param apiToken The token to authenticate your app for the (remote) API at Trusted Shops. Currently can be any `NSString`.
 @param email The email your customer used to make the purchase.
 @param orderNo A string uniquely representing the order that was made.
 @param amount The actual value of the purchase. Typically a float or double greater than 0 and with 2 digits after the decimal point.
 @param currency A string denoting the purchase the transaction was made in, e.g. `@"EUR"`.
 @param paymentType A string denoting the payment type, e.g. `@"CREDIT_CARD"`.
 @param estDeliveryDate An `NSDate` object holding your estimate for the date the purchased product will arrive at the
 customer. Should lie in the future and can be `nil`.
 @see curr
 @see paymentType
 */
+ (nullable instancetype)TRSOrderWithTrustedShopsID:(nonnull NSString *)trustedShopsID
										   apiToken:(nonnull NSString *)apiToken
											  email:(nonnull NSString *)email
											ordernr:(nonnull NSString *)orderNo
											 amount:(nonnull NSNumber *)amount
											   curr:(nonnull NSString *)currency
										paymentType:(nonnull NSString *)paymentType
									   deliveryDate:(nullable NSDate *)estDeliveryDate;

/**
 Validates a `TRSOrder` object internally.
 
 This method validates an instantiated `TRSOrder` object. In future versions of the SDK this might include a
 remote API connection, but at the moment no network traffic is caused. 
 
 The main purpose of the validation is to correctly set the `orderState`, `insuranceState`, and `nextActionFlag`
 properties. Depending on those state indicators you can adjust your UI. After that you should call
 finishWithCompletionBlock: to send the order to the Trusted Shops remote API.
 
 If you are not interested in adjusting anything after validation you can directly call
 finishWithCompletionBlock: instead.
 @param onCompletion A block that is called after the object has been validated. Its `error` parameter will be nil
 unless an error occured.
 @see finishWithCompletionBlock:
 */
- (void)validateWithCompletionBlock:(nullable void (^)(NSError *_Nullable error))onCompletion;

/**
 Sends the information contained in the `TRSOrder` object to the Trusted Shops API.
 
 This method directly sends a `TRSOrder` object to the remote API. This will result in a modal dialog box
 to be shown to the user, informing them about their status at Trusted Shops, the guarantee, etc.
 After the user has finished interacting with that dialog the onCompletion block will be called with
 `nil` as its `error` parameter.
 @param onCompletion A block that is called after the object has been sent to the Trusted Shops API. 
 Its `error` parameter will be nil unless an error occured.
 @see validateWithCompletionBlock:
 */
- (void)finishWithCompletionBlock:(nullable void (^)(NSError *_Nullable error))onCompletion;

//- (void)validateAndFinishWithCompletionBlock:(nullable void (^)(NSError *_Nullable error))onCompletion;

@end
