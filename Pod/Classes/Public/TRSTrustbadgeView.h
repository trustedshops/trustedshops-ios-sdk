#import <UIKit/UIKit.h>

/** 
 `TRSTrustbadgeView` is a subclass of `UIView` for displaying a trustmark in your application
 that can show a floating lightbox with the trustcard information of your Trusted Shops certificate.
 
 After initializing the view, you need to load the certificate data from the Trusted SHops API
 by calling `loadTrustbadgeWithFailureBlock:` or `loadTrustbadgeWithSuccessBlock:failureBlock:`
 for the view to actually display anything. Not doing so results in an empty view.
 
 The lightbox is modally presented by your application's root `UIViewController` object by default.
 Should this lead to unwanted behavior (the box showing up behind your own modally presented view,
 for example) you can set a different view controller for the presentation by setting the
 `trustcardPresentingViewController` property.
 */

@interface TRSTrustbadgeView : UIView

/** @name Creating a TRSTrustbadgeView instance 
 */

/**	
 Creates and initializes a Trustbadge view without proper API token.
 
 This method is deprecated as of version 0.2.0 of the SDK.
 It still works, but the resulting view will simply not show or react to touches. 
 Basically this is the same result that `initWithTrustedShopID:apiToken:` returns with an apiToken of `nil`.
 
 @param trustedShopsID The Trusted Shops ID for the desired Trustbadge.
 @return An initialized view object for the provided Trusted Shops ID without a proper API token.
 @see loadTrustbadgeWithFailureBlock:
 @see loadTrustbadgeWithSuccessBlock:failureBlock:
*/
- (instancetype)initWithTrustedShopsID:(NSString *)trustedShopsID DEPRECATED_MSG_ATTRIBUTE(" Use initWithTrustedShopsID:apiToken: instead.");

/** 
 Creates and initializes a Trustbadge view with a default frame.
 
 This method is the same as calling `initWithFrame:trustedShopsID:apiToken:`
 with a frame rectangle of `(0.0, 0.0, 64.0, 64.0)`.
 
 @param trustedShopsID The Trusted Shops ID for the desired Trustbadge.
 @param apiToken The token to authenticate your app for the (remote) API providing the certificate & shop data. Currently can be any `NSString`.
 @return A fully initialized view object for the provided Trusted Shops ID.
 @see loadTrustbadgeWithFailureBlock:
 @see loadTrustbadgeWithSuccessBlock:failureBlock:
 @see initWithFrame:trustedShopsID:apiToken:
 */
- (instancetype)initWithTrustedShopsID:(NSString *)trustedShopsID apiToken:(NSString *)apiToken;

/**	
 Creates and initializes a Trustbadge view.
 
 This method creates and initializes a Trustbadge view with custom frame.
 
 It is ready to be used, but unless it gets send a `loadTrustbadgeWithFailureBlock:` or a
 `loadTrustbadgeWithSuccessBlock:failureBlock:` message the seal image will be hidden and it won't react to touches.
 (After a grace delay of one second for the case that the load doesn't finish immediately).
 
 @param aRect A rectangle specifying the frame for the view.
 @param trustedShopsID The Trusted Shops ID for the desired Trustbadge.
 @param apiToken The token to authenticate your app for the (remote) API providing the certificate & shop data. Currently can be any `NSString`.
 @return A fully initialized view object for the provided Trusted Shops ID.
 @see loadTrustbadgeWithFailureBlock:
 @see loadTrustbadgeWithSuccessBlock:failureBlock:
 */
- (instancetype)initWithFrame:(CGRect)aRect
			   trustedShopsID:(NSString *)trustedShopsID
					 apiToken:(NSString *)apiToken NS_DESIGNATED_INITIALIZER;

/** @name Loading & activating the Trustbadge view.
 */

/**	
 Loads the certificate and shop data from the remote API.
 
 This method calls `loadTrustbadgeWithSuccessBlock:failureBlock:` with `nil` for the successBlock.
 
 @param failure A block that is executed in case the view was unable to retreive the shop & certificate data.
 @see loadTrustbadgeWithSuccessBlock:failureBlock:
 */
- (void)loadTrustbadgeWithFailureBlock:(void (^)(NSError *error))failure;

/**
 Loads the certificate and shop data from the remote API.
 
 This method fetches the shop & certificate data from the Trusted Shops API to make the trustbadge view
 fully active. It uses a background http request to do so. Once the data is retreived, it shows the seal 
 and enables it to react to touches (to display the trustcard).
 
 Note that the success and failure blocks are called on the main thread since you're probably interested in
 doing additional UI setup with the result.
 
 @param failure A block that is executed in case the view was unable to retreive the shop & certificate data.
 @param success A block that is executed once the data is successfully retreived.
 */
- (void)loadTrustbadgeWithSuccessBlock:(void (^)(void))success failureBlock:(void (^)(NSError *error))failure;

/** @name Properties
 */

/**	
 Defines a custom color for the trustcard look.
 
 This property defines a custom color that is used on the trustcard (which appears when the user taps
 the the `TRSTrustbadgeView`). This color is used for the buttons at the card's bottom and
 for the checkmark, lock and discussion symbols. The default color to use is #F37000
 
 @deprecated As of version 0.7.0 the trustcard is the same as is used webshops. This more interactive version does not support custom colors.
 */
@property (nonatomic, strong) UIColor *customColor DEPRECATED_ATTRIBUTE;

/** 
 The TrustedShopsID (readonly). Is set on initialization.
 */
@property (nonatomic, readonly) NSString *trustedShopsID;

/** 
 The API Token you got from Trusted Shops (readonly). Is set on initialization. Currently can be any `NSString`.
 
 Set this before calling `loadTrustbadgeWithSuccessBlock:failureBlock:` or `loadTrustbadgeWithFailureBlock:`
 */
@property (nonatomic, readonly) NSString *apiToken;

/**
 The view controller responsible for (modally) presenting the trustcard once the user taps the view.
 
 By default the trustcard gets the application's root view controller and has it modally present the trustcard
 (showing your Trusted Shops certificate). If your setup already has the root controller present a different
 scene you can define a different presenter with this property. You would usually chose the view controller
 responsible for showing the top-most visible view.
 */
@property (nonatomic, weak) UIViewController *trustcardPresentingViewController;

/**	
 A debug flag.
 
 Set this to true to only load data from the Trusted Shops test API URLs. Defaults to NO.
 It's best to do so before calling `loadTrustbadgeWithSuccessBlock:failureBlock:` or `loadTrustbadgeWithFailureBlock:`
 */
@property (nonatomic, assign) BOOL debugMode;

// TODO: add a logging property & logging functionality like on Android. Also add Icon color
@end
