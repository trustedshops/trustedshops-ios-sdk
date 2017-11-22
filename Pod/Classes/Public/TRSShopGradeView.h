//
//  TRSShopGradeView.h
//  Pods
//
//  Created by Gero Herkenrath on 13/06/16.
//
//

#import <UIKit/UIKit.h>

/**
 A constant specifying the minimum height of the view. 
 This indirectly also influences the view's width, although the latter also depends on the labels displayed under the
 stars once the view is loaded. If the text in the labels is short (depends on localization), then the width of the
 view is 2.5 times its height. If they have longer text, the width is higher. This means that the absolute minimum
 width the view can have is `kTRSShopGradingViewMinHeight * 2.5`.
 */
FOUNDATION_EXPORT CGFloat const kTRSShopGradingViewMinHeight;

/**
 `TRSShopGradeView` is a view designed to show a shop's grade.
 
 It consists of a row of five stars at the top, beneath them the grade is displayed as written text (e.g. "EXCELLENT"),
 and beneath that the grade is shown as a number in the format "x.xx/5.00".
 Font colors are fixed at the moment to black (primary) and dark grey (for the 5.00).
 Like the `TRSTrustbadgeView` this view must be loaded from the Trusted Shops backend to display anything meaningful.
 Otherwise it is just empty. Because of this you might want to add the view programmatically to a given hierarchy only
 when the load succeeds. See `loadShopGradeWithSuccessBlock:failureBlock:` for details.
 
 If the user taps on a successfully loaded `TRSShopGradeView` a link to the shop's certificate is opened in Safari.
 Unloaded views simply do nothing on tap.
 */
@interface TRSShopGradeView : UIView

/**
 The color filled stars are drawn with. Defaults to the Trusted Shops CI color ananas (yellow).
 */
@property (nonatomic, strong) UIColor *activeStarColor;
/**
 The color unfilled stars are drawn with. Defaults to a dark grey.
 */
@property (nonatomic, strong) UIColor *inactiveStarColor;
/**
 The Trusted Shops ID of the shop the view is supposed to display.
 
 You MUST set this to a valid TSID before calling `loadShopGradeWithSuccessBlock:failureBlock:`, otherwise the view
 cannot be loaded and displays nothing.
 */
@property (nonatomic, copy) NSString *tsID;
/**
 A token needed to authenticate your app to the Trusted Shops backend. 
 
 At the moment this is not needed, but you must specify a non-nil `NSString` before calling 
 `loadShopGradeWithSuccessBlock:failureBlock:`.
 */
@property (nonatomic, copy) NSString *apiToken;
/** 
 A debug flag to inform the view it is supposed to load its data not from the Trusted Shops production backend
 but the QA backend instead. 
 
 Use this during development. (Note: The URL opened in Safari when the user taps the view
 does NOT go to the QA backend even if this flag is set. This is fine since shops on QA usually also exist
 on PROD and you can't mess up anything by simply displaying a certificate anyways. Just don't be confused it the 
 grade displayed on PROD differs from what a view shows when `debugMode` is set to `YES`.)
 */
@property (nonatomic, assign) BOOL debugMode;

/**
 The overall mark as it was calculated for this shop in the Trusted Shops database. This is `nil` before
 `loadShopGradeWithSuccessBlock:failureBlock:` or `loadShopGradeWithFailureBlock:` is called.
 */
@property (readonly) NSNumber *overallMark;

/**
 The total number of reviews for this shop in the Trusted Shops database. This is `nil` before
 `loadShopGradeWithSuccessBlock:failureBlock:` or `loadShopGradeWithFailureBlock:` is called.
 */
@property (readonly) NSNumber *totalReviewCount;

/**
 A human readable, localized description of the overall mark for this shop. This is `nil` before
 `loadShopGradeWithSuccessBlock:failureBlock:` or `loadShopGradeWithFailureBlock:` is called.
 */
@property (readonly) NSString *overallMarkDescription;

/**
 Loads the grade data from the remote API.
 
 This method fetches the needed data from the Trusted Shops backend and must be called for the view to actually
 show anything. Be sure to set the view's `tsID` and `apiToken` properties before calling it.
 
 @param success A block that is executed on the main thread once the view has loaded its data. If you haven't
 added it to a view hierarchy you should do so here.
 @param failure A block that is called on the main thread if the loading encountered an error. See `TRSErrorCode` for
 the error codes provided by the `error` parameter of the block.
 */
- (void)loadShopGradeWithSuccessBlock:(void (^)(void))success failureBlock:(void (^)(NSError *error))failure;
/**
 Loads the grade data from the remote API.
 
 This method simply calls `loadShopGradeWithSuccessBlock:failureBlock:` with a `nil` for the `success` parameter.
 Be sure to set the view's `tsID` and `apiToken` properties before calling it. Also note that if you add the view to
 a hierarchy before loading it will appear empty until it is loaded.
 
 @param failure A block that is called on the main thread if the loading encountered an error. See `TRSErrorCode` for
 the error codes provided by the `error` parameter of the block.
 */
- (void)loadShopGradeWithFailureBlock:(void (^)(NSError *error))failure;

@end
