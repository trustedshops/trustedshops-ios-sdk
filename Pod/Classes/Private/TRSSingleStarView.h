//
//  TRSSingleStarView.h
//  Pods
//
//  Refactored by Gero Herkenrath on 13/06/16.
//  (Class was formerly TRSStarView)
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT CGFloat const kTRSSingleStarViewMinHeight;

@interface TRSSingleStarView : UIView

@property (nonatomic, readonly) NSNumber *percentFilled;
@property (nonatomic, strong) UIColor *activeStarColor;
@property (nonatomic, strong) UIColor *inactiveStarColor;

- (instancetype)initWithFrame:(CGRect)frame percentFilled:(NSNumber *)percentFilled NS_DESIGNATED_INITIALIZER;

+ (instancetype)filledStarWithSidelength:(CGFloat)length;
+ (instancetype)emptyStarWithSidelength:(CGFloat)length;
+ (instancetype)starWithSidelength:(CGFloat)length percentFilled:(NSNumber *)percentFilled;

@end
