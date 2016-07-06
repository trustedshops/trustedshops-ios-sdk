//
//  TRSProductRatingView.h
//  Pods
//
//  Created by Gero Herkenrath on 05/07/16.
//
//

#import <UIKit/UIKit.h>
#import "TRSProductSimpleRatingView.h"

FOUNDATION_EXPORT CGFloat const kTRSProductRatingViewMinHeight;

@interface TRSProductRatingView : TRSProductSimpleRatingView

@property (nonatomic, assign) NSTextAlignment alignment;
@property (nonatomic, assign) BOOL useOnlyOneLine; // defaults to NO
@property (nonatomic, readonly) CGFloat minHeight; // 10 or 20, depending on useOnlyOneLine

@end
