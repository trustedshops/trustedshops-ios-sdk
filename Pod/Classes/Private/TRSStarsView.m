//
//  TRSStarsView.m
//  Pods
//
//  Created by Gero Herkenrath on 13/06/16.
//  (Class was formerly TRSRatingView)
//

#import "TRSStarsView.h"
#import "NSNumber+TRSRating.h"
#import "TRSSingleStarView.h"

NSUInteger const kTRSStarsViewNumberOfStars = 5; // never set this below 1!

NSString *const kTRSStarsViewIntegralOfRatingKey = @"kTRSStarsViewIntegralOfRatingKey";
NSString *const kTRSStarsViewFractionalOfRatingKey = @"kTRSStarsViewFractionalOfRatingKey";
NSString *const kTRSStarsViewActiveStarColorKey = @"kTRSStarsViewActiveStarColorKey";
NSString *const kTRSStarsViewInactiveStarColorKey = @"kTRSStarsViewInactiveStarColorKey";

@interface TRSStarsView ()

@property (nonatomic, strong) NSNumber *integralOfRating;
@property (nonatomic, strong) NSNumber *fractionalOfRating;
@property (nonatomic, strong) NSArray *starViews;

- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

@end

@implementation TRSStarsView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame rating:(NSNumber *)rating {
	self = [super initWithFrame:frame];
	if (self) {
		if (rating == nil || rating.doubleValue > 5.0) {
			rating = @5;
		} else if (rating.doubleValue < 0.0) {
			rating = @0;
		}
		self.integralOfRating = [rating trs_integralPart];
		self.fractionalOfRating = [rating trs_fractionalPart];
		[self finishInit];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	return [self initWithFrame:frame rating:@5];
}

- (instancetype)initWithRating:(NSNumber *)rating {
	return [self initWithFrame:CGRectZero rating:rating];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		self.integralOfRating = [coder decodeObjectForKey:kTRSStarsViewIntegralOfRatingKey];
		self.fractionalOfRating = [coder decodeObjectForKey:kTRSStarsViewFractionalOfRatingKey];
		[self finishInit];
		self.activeStarColor = [coder decodeObjectForKey:kTRSStarsViewActiveStarColorKey];
		self.inactiveStarColor = [coder decodeObjectForKey:kTRSStarsViewInactiveStarColorKey];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:self.integralOfRating forKey:kTRSStarsViewIntegralOfRatingKey];
	[aCoder encodeObject:self.fractionalOfRating forKey:kTRSStarsViewFractionalOfRatingKey];
	[aCoder encodeObject:self.activeStarColor forKey:kTRSStarsViewActiveStarColorKey];
	[aCoder encodeObject:self.inactiveStarColor forKey:kTRSStarsViewInactiveStarColorKey];
}

- (void)finishInit {
	[self sizeToFit];
	
	// create the stars (our bounds now have the correct aspect ratio)
	CGFloat starLength = self.bounds.size.height;
	self.starViews = [self createStarsWithLength:starLength];
	for (UIView *star in self.starViews) {
		[self addSubview:star];
	}
	_activeStarColor = [(TRSSingleStarView *)self.starViews.firstObject activeStarColor];
	_inactiveStarColor = [(TRSSingleStarView *)self.starViews.firstObject inactiveStarColor];
}

#pragma mark - Convenience initializers

+ (instancetype)starsWithRating:(NSNumber *)rating {
	return [[TRSStarsView alloc] initWithRating:rating];
}

#pragma mark - Custom getters & setters

- (NSNumber *)rating {
	return [NSNumber numberWithFloat:(self.integralOfRating.floatValue + self.fractionalOfRating.floatValue)];
}

- (void)setActiveStarColor:(UIColor *)activeStarColor {
	if (![activeStarColor isEqual:_activeStarColor]) {
		_activeStarColor = activeStarColor;
		for (TRSSingleStarView *star in self.starViews) {
			star.activeStarColor = _activeStarColor;
		}
	}
}

- (void)setInactiveStarColor:(UIColor *)inactiveStarColor {
	if (![inactiveStarColor isEqual:_inactiveStarColor]) {
		_inactiveStarColor = inactiveStarColor;
		for (TRSSingleStarView *star in self.starViews) {
			star.inactiveStarColor = _inactiveStarColor;
		}
	}
}

#pragma mark - Resizing behavior (min size)

- (CGSize)sizeThatFits:(CGSize)size {
	CGFloat lengthPerStar = MIN(size.width / kTRSStarsViewNumberOfStars, size.height); // note that stars are always square
	if (lengthPerStar < kTRSSingleStarViewMinHeight) { // this is important!
		lengthPerStar = kTRSSingleStarViewMinHeight;
	}
	return CGSizeMake(lengthPerStar * kTRSStarsViewNumberOfStars, lengthPerStar);
}

#pragma marks - Drawing / Subview layout update

- (void)layoutSubviews {
	[self sizeToFit];
	CGFloat starLength = self.bounds.size.height;
	CGRect starFrame = CGRectMake(0.0, 0.0, starLength, starLength);
	for (UIView *star in self.starViews) {
		star.frame = starFrame;
		starFrame.origin.x += starLength;
		[star setNeedsDisplay]; // force redraw to avoid aliasing
	}
}

#pragma mark - Helper methods

- (NSArray *)createStarsWithLength:(CGFloat)length {
	NSMutableArray *starViews = [NSMutableArray arrayWithCapacity:kTRSStarsViewNumberOfStars];
	
	CGRect newFrame = CGRectMake(0.0, 0.0, length, length);
	BOOL addedFractionalStar = NO;
	for (NSUInteger idx = 0; idx < kTRSStarsViewNumberOfStars; idx++) {
		UIView *starView;
		
		if (idx < [self.integralOfRating unsignedIntegerValue]) {
			starView = [TRSSingleStarView filledStarWithSidelength:length];
		} else if ([self.fractionalOfRating floatValue] > 0.0f && !addedFractionalStar) {
			starView = [TRSSingleStarView starWithSidelength:length percentFilled:self.fractionalOfRating];
			addedFractionalStar = YES;
		} else {
			starView = [TRSSingleStarView emptyStarWithSidelength:length];
		}
		
		// provide an initial frame (note the other methods already guarantee the overall frame is big enough for this)
		starView.frame = newFrame;
		newFrame.origin.x += length;
		
		[starViews addObject:starView];
	}
	
	return [NSArray arrayWithArray:starViews];
}

@end
