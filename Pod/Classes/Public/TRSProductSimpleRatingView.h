//
//  TRSProductSimpleRatingView.h
//  Pods
//
//  Created by Gero Herkenrath on 05/07/16.
//
//

#import <UIKit/UIKit.h>
#import "TRSProductBaseView.h"

FOUNDATION_EXPORT CGFloat const kTRSProductSimpleRatingViewMinHeight;

@interface TRSProductSimpleRatingView : TRSProductBaseView

@property (nonatomic, strong) UIColor *activeStarColor;
@property (nonatomic, strong) UIColor *inactiveStarColor;

@end
