//
//  TRSShopSimpleRatingView.h
//  Pods
//
//  Created by Gero Herkenrath on 14/06/16.
//
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT CGFloat const kTRSShopSimpleRatingViewMinHeight; // width is obviously 5 times this

@interface TRSShopSimpleRatingView : UIView

@property (nonatomic, strong) UIColor *activeStarColor;
@property (nonatomic, strong) UIColor *inactiveStarColor;

- (void)loadShopSimpleRatingWithSuccessBlock:(void (^)(void))success failureBlock:(void (^)(NSError *error))failure;
- (void)loadShopSimpleRatingWithFailureBlock:(void (^)(NSError *error))failure;

@end
