//
//  TRSShopGradeView.h
//  Pods
//
//  Created by Gero Herkenrath on 13/06/16.
//
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT CGFloat const kTRSShopGradingViewMinHeight;

@interface TRSShopGradeView : UIView

@property (nonatomic, strong) UIColor *activeStarColor;
@property (nonatomic, strong) UIColor *inactiveStarColor;

- (void)loadShopGradeWithSuccessBlock:(void (^)(void))success failureBlock:(void (^)(NSError *error))failure;
- (void)loadShopGradeWithFailureBlock:(void (^)(NSError *error))failure;

@end
