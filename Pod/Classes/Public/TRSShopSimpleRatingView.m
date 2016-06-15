//
//  TRSShopSimpleRatingView.m
//  Pods
//
//  Created by Gero Herkenrath on 14/06/16.
//

#import "TRSShopSimpleRatingView.h"
#import "TRSStarsView.h"
#import "UIColor+TRSColors.h"

CGFloat const kTRSShopSimpleRatingViewMinHeight = 16.0; // note: ensure this is not smaller than the one defined in TRSSingleStarView.m!

@interface TRSShopSimpleRatingView ()

@property (nonatomic, strong) UIView *starPlaceholder;
@property (nonatomic, strong) TRSStarsView * starsView;

@end

@implementation TRSShopSimpleRatingView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self finishInit];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self finishInit];
	}
	return self;
}

- (void)finishInit {
	_activeStarColor = [UIColor trs_filledStarColor];
	_inactiveStarColor = [UIColor trs_nonFilledStarColor];
	
	[self sizeToFit];
	
	self.starPlaceholder = [[UIView alloc] initWithFrame:[self frameForStars]];
	self.starPlaceholder.backgroundColor = [UIColor clearColor];
	[self addSubview:self.starPlaceholder];
	
}

#pragma mark - Loading data from TS Backend

- (void)loadShopSimpleRatingWithSuccessBlock:(void (^)(void))success failureBlock:(void (^)(NSError *error))failure {
	// note (dirty cheat): due to the rendering chain it's important to do this asynchronously, otherwise
	// we might get the wrong frame for this. Once it loads from the backend that's not to important,
	// but if the request is e.g. cached, it might screw us.
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		self.starsView = [[TRSStarsView alloc] initWithFrame:self.starPlaceholder.bounds rating:@4.3];
		self.starsView.activeStarColor = _activeStarColor;
		self.starsView.inactiveStarColor = _inactiveStarColor;
		[self.starPlaceholder addSubview:self.starsView];
		if (success) {
			success();
		}
	});
}

- (void)loadShopSimpleRatingWithFailureBlock:(void (^)(NSError *error))failure {
	[self loadShopSimpleRatingWithSuccessBlock:nil failureBlock:failure];
}

#pragma mark - Custom setters

- (void)setActiveStarColor:(UIColor *)activeStarColor {
	if (![activeStarColor isEqual:_activeStarColor]) {
		_activeStarColor = activeStarColor;
		if (self.starsView) {
			self.starsView.activeStarColor = _activeStarColor;
		}
	}
}

- (void)setInactiveStarColor:(UIColor *)inactiveStarColor {
	if (![inactiveStarColor isEqual:_inactiveStarColor]) {
		_inactiveStarColor = inactiveStarColor;
		if (self.starsView) {
			self.starsView.inactiveStarColor = _inactiveStarColor;
		}
	}
}

#pragma mark - Resizing behavior (min size)

- (CGSize)sizeThatFits:(CGSize)size {
	if (size.height < kTRSShopSimpleRatingViewMinHeight) {
		size.height = kTRSShopSimpleRatingViewMinHeight;
	}
	
	if (size.width < kTRSShopSimpleRatingViewMinHeight * kTRSStarsViewNumberOfStars) {
		size.width = kTRSShopSimpleRatingViewMinHeight * kTRSStarsViewNumberOfStars;
	}
	return size;
}

#pragma mark - Drawing

- (void)layoutSubviews {
	[super layoutSubviews];
	[self sizeToFit];
	self.starPlaceholder.frame = [self frameForStars];
	
	if (self.starsView) {
		self.starsView.frame = self.starPlaceholder.bounds;
	}
}

#pragma mark - Helper methods

// assumes aspect ratio of parent is correct
- (CGRect)frameForStars {
	
	CGFloat lengthPerStar = MIN(self.bounds.size.width / kTRSStarsViewNumberOfStars, self.bounds.size.height);
	CGRect theFrame = CGRectMake(0.0, 0.0, lengthPerStar * kTRSStarsViewNumberOfStars, lengthPerStar);
	// center the view in ourselves
	theFrame.origin.x = self.bounds.size.width / 2.0 - theFrame.size.width / 2.0;
	theFrame.origin.y = self.bounds.size.height / 2.0 - theFrame.size.height / 2.0;
	
	return theFrame;
}

@end
