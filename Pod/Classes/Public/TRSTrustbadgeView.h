#import <UIKit/UIKit.h>

/**
 *	@class TRSTrustbadgeView
 *	@discussion		@c TRSTrustbadgeView is a subclass of @c UIView for displaying a trustmark in your application
 *					that can show a floating dialogue with the trustcard information of your Trusted Shops certificate.
 */

@interface TRSTrustbadgeView : UIView

/**
 *	Creates and initializes a Trustbadge view without proper API token.
 *	@discussion	This method is deprecated with version 0.2.0-alpha of the SDK.
 *		It still works, but the resulting object will simply display a washed out seal with the
 *		word "OFFLINE" over it. Basically this is the same result that
 *		@c initWithTrustedShopID:apiToken: returns with an apiToken of @c nil.
 *	@param trustedShopsID The Trusted Shops ID for the desired Trustbadge.
 *	@return An initialized view object for the provided Trusted Shops ID without a proper API token.
 *	@see @c loadTrustbadgeWithFailureBlock:
 *	@see @c loadTrustbadgeWithSuccessBlock:failureBlock:
*/
- (instancetype)initWithTrustedShopsID:(NSString *)trustedShopsID DEPRECATED_MSG_ATTRIBUTE(" Use initWithTrustedShopsID:apiToken: instead.");

/**
 *	Creates and initializes a Trustbadge view with a default frame.
 *	@discussion	This method is the same as calling @c initWithFrame:TrustedShopsID:trustedShopsID:
 *		with a frame rectangle of <tt>(0.0f, 0.0f, 64.0f, 64.0f)</tt>.
 *	@param trustedShopsID The Trusted Shops ID for the desired Trustbadge.
 *	@param apiToken The token to authenticate your app for the (remote) API providing the certificate & shop data.
 *	@return A fully initialized view object for the provided Trusted Shops ID.
 *	@see @c loadTrustbadgeWithFailureBlock:
 *	@see @c loadTrustbadgeWithSuccessBlock:failureBlock:
 *	@see @c initWithFrame:TrustedShopsID:trustedShopsID:
 */
- (instancetype)initWithTrustedShopsID:(NSString *)trustedShopsID apiToken:(NSString *)apiToken;

/**
 *	Creates and initializes a Trustbadge view.
 *	@discussion	This method creates and initializes a Trustbadge view with custom frame.
 *
 *		It is ready to be used, but unless it gets send a @c loadTrustbadgeWithFailureBlock: or a 
 *		@c loadTrustbadgeWithSuccessBlock:failureBlock: message the seal image is transparent, an "OFFLINE" 
 *		label is placed over it, and it won't react to touches.
 *
 *		We might implement a grace period after initialization during which the full logo is displayed anyways.
 *	@param aRect A rectangle specifying the frame for the view.
 *	@param trustedShopsID The Trusted Shops ID for the desired Trustbadge.
 *	@param apiToken The token to authenticate your app for the (remote) API providing the certificate & shop data.
 *	@return A fully initialized view object for the provided Trusted Shops ID.
 *	@see @c loadTrustbadgeWithFailureBlock:
 *	@see @c loadTrustbadgeWithSuccessBlock:failureBlock:
 */
- (instancetype)initWithFrame:(CGRect)aRect
			   TrustedShopsID:(NSString *)trustedShopsID
					 apiToken:(NSString *)apiToken NS_DESIGNATED_INITIALIZER;

/**
 *	Loads the certificate and shop data from the remote API.
 *	@discussion This method fetches the shop & certificate data from the Trusted Shops API to make the trustbadge view
 *		fully active. It uses a background http request to do so. Once the data is retreived, it hides the "OFFLINE"
 *		label from the view and enables it to react to touches (to display the trustcard).
 *
 *		Note that the success and failure blocks are called on the delegate queue.
 *	@param failure A block that is executed in case the view was unable to retreive the shop & certificate data.
 *	@param success A block that is executed once the data is successfully retreived.
 */
- (void)loadTrustbadgeWithSuccessBlock:(void (^)())success failureBlock:(void (^)(NSError *error))failure;

/**
 *	Loads the certificate and shop data from the remote API.
 *	@discussion This method calls @c loadTrustbadgeWithSuccessBlock:failureBlock: with @c nil for the successBlock.
 *	@param failure A block that is executed in case the view was unable to retreive the shop & certificate data.
 *	@see @c loadTrustbadgeWithSuccessBlock:failureBlock:
 */
- (void)loadTrustbadgeWithFailureBlock:(void (^)(NSError *error))failure;

/** The TrustedShopsID. Set this before calling @c loadTrustbadgeWithSuccessBlock:failureBlock:
 *		or @c loadTrustbadgeWithFailureBlock:
 */
@property (nonatomic, copy, readonly) NSString *trustedShopsID;

/** The API Token you got from Trusted Shops. Set this before calling @c loadTrustbadgeWithSuccessBlock:failureBlock:
 *		or @c loadTrustbadgeWithFailureBlock:
 */
@property (nonatomic, copy, readonly) NSString *apiToken;

@end
