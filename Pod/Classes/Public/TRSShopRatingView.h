//
//  TRSShopRatingView.h
//  Pods
//
//  Created by Gero Herkenrath on 07/06/16.
//
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT CGFloat const kTRSShopRatingViewMinHeight;

@interface TRSShopRatingView : UIView

@property (nonatomic, strong) UIColor *activeStarColor;
@property (nonatomic, strong) UIColor *inactiveStarColor;
@property (nonatomic, assign) NSTextAlignment alignment;
@property (nonatomic, copy) NSString *tsID;
@property (nonatomic, copy) NSString *apiToken;
@property (nonatomic, assign) BOOL debugMode;

- (void)loadShopRatingWithSuccessBlock:(void (^)(void))success failureBlock:(void (^)(NSError *error))failure;
- (void)loadShopRatingWithFailureBlock:(void (^)(NSError *error))failure;

@end
