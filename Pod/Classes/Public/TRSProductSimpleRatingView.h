//
//  TRSProductSimpleRatingView.h
//  Pods
//
//  Created by Gero Herkenrath on 05/07/16.
//
//

#import <UIKit/UIKit.h>
#import "TRSProductBaseView.h"

/**
 The minimum height that a `TRSProductSimpleRatingView` can have. This also defines the minimum width as five times
 this constant (the stars have a fixed aspect ration and there are always five of them).
 */
FOUNDATION_EXPORT CGFloat const kTRSProductSimpleRatingViewMinHeight;

/**
 `TRSProductSimpleRatingView` displays a simple row of five stars, filled accordingly to a product's rating.
 
 This class is the first concrete subclass of `TRSProductBaseView` (and thus `TRSPrivateBasicDataView`) that displays 
 anything to the user. After `loadViewDataFromBackendWithSuccessBlock:failureBlock:` is called, it uses the 
 overall rating of its associated product to draw a row of five stars, filled proportionally to the rating.
 
 The colors (fill and background) of these stars can be freely defined.
 */
@interface TRSProductSimpleRatingView : TRSProductBaseView

/**
 The color that is used to fill the stars accordingly to the product's rating.
 */
@property (nonatomic, strong) UIColor *activeStarColor;
/**
 The background color used for the five stars.
 */
@property (nonatomic, strong) UIColor *inactiveStarColor;

@end
