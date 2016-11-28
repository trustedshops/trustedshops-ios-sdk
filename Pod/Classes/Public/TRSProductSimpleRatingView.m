//
//  TRSProductSimpleRatingView.m
//  Pods
//
//  Created by Gero Herkenrath on 05/07/16.
//
//

#import "TRSProductSimpleRatingView.h"
#import "TRSStarsView.h"
#import "TRSSingleStarView.h" // to get the minimum height constant
#import "UIColor+TRSColors.h"

// import the private headers so I can access the data structures
#import "TRSProductBaseView+Private.h"
#import "TRSPrivateBasicDataView+Private.h"

// public constant
CGFloat const kTRSProductSimpleRatingViewMinHeight = 16.0; // should not be smaller than kTRSSingleStarViewMinHeight
// private constants (used for encoding/decoding
NSString *const kTRSProductSimpleRatingViewActiveColorKey = @"kTRSProductSimpleRatingViewActiveColorKey";
NSString *const kTRSProductSimpleRatingViewInactiveColorKey = @"kTRSProductSimpleRatingViewInactiveColorKey";

@interface TRSProductSimpleRatingView ()

@property (nonatomic, strong) TRSStarsView *stars;
@property (nonatomic, strong) UIView *starsPlaceholder;

@end

@implementation TRSProductSimpleRatingView

#pragma mark - initWithCoder & encodeWithCoder additions

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder]; // this also calls finishInit!
	if (self) {
		_activeStarColor = [aDecoder decodeObjectForKey:kTRSProductSimpleRatingViewActiveColorKey];
		_inactiveStarColor = [aDecoder decodeObjectForKey:kTRSProductSimpleRatingViewInactiveColorKey];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:self.activeStarColor forKey:kTRSProductSimpleRatingViewActiveColorKey];
	[aCoder encodeObject:self.inactiveStarColor forKey:kTRSProductSimpleRatingViewInactiveColorKey];
}

#pragma mark - Resizing behavior (min size)

- (CGSize)sizeThatFits:(CGSize)size {
	CGFloat myMin = MAX(kTRSProductSimpleRatingViewMinHeight, kTRSSingleStarViewMinHeight);
	if (size.height < myMin) {
		size.height = myMin;
	}
	
	if (size.width < myMin * kTRSStarsViewNumberOfStars) {
		size.width = myMin * kTRSStarsViewNumberOfStars;
	}
	return size;
}

#pragma mark - Drawing

- (void)layoutSubviews {
	[super layoutSubviews];
	[self sizeToFit];
	self.starsPlaceholder.frame = [self frameForStars];
	
	if (self.stars) {
		self.stars.frame = self.starsPlaceholder.bounds;
	}
}

#pragma mark - Custom setters

- (void)setActiveStarColor:(UIColor *)activeStarColor {
	if (![activeStarColor isEqual:_activeStarColor]) {
		_activeStarColor = activeStarColor;
		if (self.stars) {
			self.stars.activeStarColor = _activeStarColor;
		}
	}
}

- (void)setInactiveStarColor:(UIColor *)inactiveStarColor {
	if (![inactiveStarColor isEqual:_inactiveStarColor]) {
		_inactiveStarColor = inactiveStarColor;
		if (self.stars) {
			self.stars.inactiveStarColor = _inactiveStarColor;
		}
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

#pragma mark - Methods to override defined by private TRSPrivateBasicDataView

- (void)finishInit {
	_activeStarColor = [UIColor trs_filledStarColor];
	_inactiveStarColor = [UIColor trs_nonFilledStarColor];
	
	[self sizeToFit];
	
	_starsPlaceholder = [[UIView alloc] initWithFrame:[self frameForStars]];
	_starsPlaceholder.backgroundColor = [UIColor clearColor];
	[self addSubview:_starsPlaceholder];
}

- (void)finishLoading {
	self.stars = [[TRSStarsView alloc] initWithFrame:self.starsPlaceholder.bounds rating:self.overallMark];
	self.stars.activeStarColor = _activeStarColor;
	self.stars.inactiveStarColor = _inactiveStarColor;
	[self.starsPlaceholder addSubview:self.stars];
}

@end
