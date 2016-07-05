//
//  TRSProductBaseView.h
//  Pods
//
//  Created by Gero Herkenrath on 04/07/16.
//
//

/*
 Although this class is not technically abstract (it does not throw any exceptions), you should not use
 it directly. It serves as a superclass for TRSProductSimpleRatingView, TRSProductRatingView, and TRSProductGradeView. 
 and does not show anything on its own, even when the data was loaded from the Trusted Shops backend.
 Instead, it will log out statements to the console when you try to call loadViewDataFromBackendWithSuccessBlock:failureBlock:
 informing you that it won't to anything with the retrieved data.
 */

#import <UIKit/UIKit.h>
#import "TRSPrivateBasicDataView.h"

@interface TRSProductBaseView : TRSPrivateBasicDataView

@property (nonatomic, copy) NSString *SKU;

- (instancetype)initWithFrame:(CGRect)frame
			   trustedShopsID:(NSString *)tsID
					 apiToken:(NSString *)apiToken
						  SKU:(NSString *)SKU NS_DESIGNATED_INITIALIZER;

@end
