//
//  TRSSingleStarView.m
//  Pods
//
//  Refactored by Gero Herkenrath on 13/06/16.
//  (Class was formerly TRSStarView)
//

#import "TRSSingleStarView.h"
#import "UIColor+TRSColors.h"

CGFloat const kTRSSingleStarViewMinHeight = 10.0;
NSString *const kTRSSingleStarViewPercentFilledKey = @"kTRSSingleStarViewPercentFilledKey";
NSString *const kTRSSingleStarViewActiveStarColorKey = @"kTRSSingleStarViewActiveStarColorKey";
NSString *const kTRSSingleStarViewInactiveStarColorKey = @"kTRSSingleStarViewInactiveStarColorKey";

@interface TRSSingleStarView ()

@property (nonatomic, strong, readwrite) NSNumber *percentFilled;

- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

@end

@implementation TRSSingleStarView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame percentFilled:(NSNumber *)percentFilled {
	self = [super initWithFrame:frame];
	if (self) {
		if (percentFilled == nil || percentFilled.doubleValue > 1.0) {
			percentFilled = @1;
		} else if (percentFilled.doubleValue < 0.0) {
			percentFilled = @0;
		}
		self.percentFilled = percentFilled;
		[self finishInit];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	return [self initWithFrame:frame percentFilled:@1];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		self.percentFilled = [coder decodeObjectForKey:kTRSSingleStarViewPercentFilledKey];
		[self finishInit];
		self.activeStarColor = [coder decodeObjectForKey:kTRSSingleStarViewActiveStarColorKey];
		self.inactiveStarColor = [coder decodeObjectForKey:kTRSSingleStarViewInactiveStarColorKey];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:self.percentFilled forKey:kTRSSingleStarViewPercentFilledKey];
	[aCoder encodeObject:self.activeStarColor forKey:kTRSSingleStarViewActiveStarColorKey];
	[aCoder encodeObject:self.inactiveStarColor forKey:kTRSSingleStarViewInactiveStarColorKey];
}

- (void)finishInit {
	[self sizeToFit];
	
	_activeStarColor = [UIColor trs_filledStarColor];
	_inactiveStarColor = [UIColor trs_nonFilledStarColor];
	self.backgroundColor = [UIColor clearColor];
}

#pragma mark - Convenience class initializers

+ (instancetype)filledStarWithSidelength:(CGFloat)length {
	return [[TRSSingleStarView alloc] initWithFrame:CGRectMake(0.0, 0.0, length, length) percentFilled:@1];
}

+ (instancetype)emptyStarWithSidelength:(CGFloat)length {
	return [[TRSSingleStarView alloc] initWithFrame:CGRectMake(0.0, 0.0, length, length) percentFilled:@0];
}

+ (instancetype)starWithSidelength:(CGFloat)length percentFilled:(NSNumber *)percentFilled {
	return [[TRSSingleStarView alloc] initWithFrame:CGRectMake(0.0, 0.0, length, length) percentFilled:percentFilled];
}

#pragma mark - Custom setters for color

- (void)setActiveStarColor:(UIColor *)activeStarColor {
	if (![activeStarColor isEqual:_activeStarColor]) {
		_activeStarColor = activeStarColor;
		[self setNeedsDisplay];
	}
}

- (void)setInactiveStarColor:(UIColor *)inactiveStarColor {
	if (![inactiveStarColor isEqual:_inactiveStarColor]) {
		_inactiveStarColor = inactiveStarColor;
		[self setNeedsDisplay];
	}
}

#pragma mark - Resizing behavior (min size)

- (CGSize)sizeThatFits:(CGSize)size {
	CGFloat length = MAX(size.width, size.height); // only allow square frames!
	length = MAX(length, kTRSSingleStarViewMinHeight);
	return CGSizeMake(length, length);
}

- (CGSize)intrinsicContentSize {
	return self.bounds.size;
}

#pragma mark - Drawing

- (void)layoutSubviews {
	[super layoutSubviews];
	[self sizeToFit];
}

- (void)drawRect:(CGRect)rect {
	[self fillPath:[self starPath]];
}

#pragma mark - Helper methods

- (UIBezierPath *)starPath {
	CGRect frame = self.bounds;
	
	CGPoint a = CGPointMake(CGRectGetMaxX(frame) / 2.0f , CGRectGetMinY(frame)         );
	CGPoint b = CGPointMake(CGRectGetMaxX(frame)        , CGRectGetMaxY(frame) * 0.362f);
	CGPoint c = CGPointMake(CGRectGetMaxX(frame) * 0.81f, CGRectGetMaxY(frame) * 0.95f );
	CGPoint d = CGPointMake(CGRectGetMaxX(frame) * 0.19f, CGRectGetMaxY(frame) * 0.95f );
	CGPoint e = CGPointMake(CGRectGetMinX(frame)        , CGRectGetMaxY(frame) * 0.362f);
	
	UIBezierPath* path = [UIBezierPath bezierPath];
	
	[path moveToPoint:a];
	[path addLineToPoint:c];
	[path addLineToPoint:e];
	[path addLineToPoint:b];
	[path addLineToPoint:d];
	[path addLineToPoint:a];
	[path closePath];
	
	[path addClip];
	
	return path;
}

- (void)fillPath:(UIBezierPath *)path {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetAllowsAntialiasing(context, YES);
	
	UIColor *startColor = self.activeStarColor != nil ? self.activeStarColor : [UIColor clearColor];
	UIColor *endColor = self.inactiveStarColor != nil ? self.inactiveStarColor : [UIColor clearColor];
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSArray* gradientColors = @[(id)startColor.CGColor, (id)endColor.CGColor, (id)endColor.CGColor];
	
	CGFloat percentFilled = [self.percentFilled floatValue];
	CGFloat gradientLocations[] = {percentFilled, percentFilled, percentFilled};
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
	
	CGRect bounds = CGPathGetBoundingBox(path.CGPath);
	CGPoint start = CGPointMake(CGRectGetMinX(bounds), CGRectGetMidY(bounds));
	CGPoint end = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMidY(bounds));
	CGContextDrawLinearGradient(context, gradient, start, end, 0);
	
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
	CGContextSaveGState(context);
}


@end
