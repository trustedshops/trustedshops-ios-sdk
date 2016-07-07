//
//  TRSProductBaseView.h
//  Pods
//
//  Created by Gero Herkenrath on 04/07/16.
//
//

#import <UIKit/UIKit.h>
#import "TRSPrivateBasicDataView.h"

/**
 `TRSProductBaseView` is both, a concrete subclass of `TRSPrivateBasicDataView` and a common superclass to all views
 responsible for displaying the grade and/or rating of a product from the Trusted Shops database.
 
 Although this class is not technically abstract (it does not throw any exceptions even if you call
 `loadViewDataFromBackendWithSuccessBlock:failureBlock:`), you should not use it directly. 
 It serves as a superclass for `TRSProductSimpleRatingView` and `TRSProductRatingView`
 and does not show anything on its own, even when the data was.
 Instead, it will log out statements to the console when you try to call loadViewDataFromBackendWithSuccessBlock:failureBlock:
 informing you that it won't do anything with the retrieved data.
 */
@interface TRSProductBaseView : TRSPrivateBasicDataView

/**
 The SKU (stock keeping unit) that identifies the product in the Trusted Shops database (together with the tsID).
 */
@property (nonatomic, copy) NSString *SKU;

/**
 The designated initializer for all views displaying product grade and rating data.
 
 @param frame The frame for the view.
 @param tsID the Trusted Shops shop ID the view uses to load its data from the backend.
 @param apiToken The client token the view uses to load its data from the backend. At the moment this is not needed and can be
 any `NSString`, but it must not be nil.
 @param SKU The SKU (stock keeping unit) that identifies the product in the Trusted Shops database.
 */
- (instancetype)initWithFrame:(CGRect)frame
			   trustedShopsID:(NSString *)tsID
					 apiToken:(NSString *)apiToken
						  SKU:(NSString *)SKU NS_DESIGNATED_INITIALIZER;

@end
