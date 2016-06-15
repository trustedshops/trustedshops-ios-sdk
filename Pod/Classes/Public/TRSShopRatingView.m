//
//  TRSShopRatingView.m
//  Pods
//
//  Created by Gero Herkenrath on 07/06/16.
//

#import "TRSShopRatingView.h"
#import "TRSStarsView.h"
#import "UIColor+TRSColors.h"
#import "TRSViewCommons.h"

CGFloat const kTRSShopRatingViewMinHeight = 40.0;
NSString *const kTRSShopRatingViewFontName = @"Arial"; // ensure this is on the system!
#define kTRSShopRatingViewStarsHeightToViewRatio (0.5)
#define kTRSShopRatingViewGradeLabelHeightToViewRatio (0.4)
#define kTRSShopRatingViewGradingFontDifferenceRatio (12.0 / 10.0)

@interface TRSShopRatingView ()

@property (nonatomic, strong) UIView *starPlaceholder;
@property (nonatomic, strong) TRSStarsView *starsView;
@property (nonatomic, strong) UILabel *gradeLabel;

@end

@implementation TRSShopRatingView

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
	
	_alignment = NSTextAlignmentNatural;
	
	[self sizeToFit];
	
	self.starPlaceholder = [[UIView alloc] initWithFrame:[self frameForStars]];
	self.starPlaceholder.backgroundColor = [UIColor clearColor];
	[self addSubview:self.starPlaceholder];
	
	self.gradeLabel = [[UILabel alloc] initWithFrame:[self frameForGradeLabel]];
	self.gradeLabel.backgroundColor = [UIColor clearColor];
	self.gradeLabel.font = [UIFont fontWithName:kTRSShopRatingViewFontName size:self.gradeLabel.font.pointSize]; // size will be adapted anyways
	self.gradeLabel.text = @"-.--/-.-- (----)";
//	self.gradeLabel.text = @"4.89/5.00 (1.363 Bewertungen)";
	self.gradeLabel.textAlignment = self.alignment;
	[self addSubview:self.gradeLabel];
	
}

#pragma mark - Loading data from TS Backend

- (void)loadShopRatingWithSuccessBlock:(void (^)(void))success failureBlock:(void (^)(NSError *error))failure {
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

- (void)loadShopRatingWithFailureBlock:(void (^)(NSError *error))failure {
	[self loadShopRatingWithSuccessBlock:nil failureBlock:failure];
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

- (void)setAlignment:(NSTextAlignment)alignment {
	if (alignment != _alignment) {
		_alignment = alignment;
		self.gradeLabel.textAlignment = _alignment;
		[self setNeedsLayout]; // might not be needed, but I didn't check all cases, so whatever...
	}
}

#pragma mark - Resizing behavior (min size)

- (CGSize)sizeThatFits:(CGSize)size {
	if (size.height < kTRSShopRatingViewMinHeight) {
		size.height = kTRSShopRatingViewMinHeight;
	}
	CGFloat gradeTextLabelWidth = [TRSViewCommons widthForLabel:self.gradeLabel
														withHeight:size.height * kTRSShopRatingViewGradeLabelHeightToViewRatio
												optimalFontSize:NULL
										 smallerCharactersScale:1.0 / kTRSShopRatingViewGradingFontDifferenceRatio];
	if (gradeTextLabelWidth < kTRSShopRatingViewMinHeight * kTRSShopRatingViewStarsHeightToViewRatio * 5.0) {
		gradeTextLabelWidth = kTRSShopRatingViewMinHeight * kTRSShopRatingViewStarsHeightToViewRatio * 5.0;
	}
	if (size.width < gradeTextLabelWidth) {
		size.width = gradeTextLabelWidth;
	}
	if (size.width < self.starPlaceholder.bounds.size.width) {
		size.width = self.starPlaceholder.bounds.size.width;
	}
	return size;
}

#pragma mark - Drawing

- (void)layoutSubviews {
	[super layoutSubviews];
	[self sizeToFit];
	self.starPlaceholder.frame = [self frameForStars];
	self.gradeLabel.frame = [self frameForGradeLabel];
	CGFloat optimalSize = [TRSViewCommons optimalHeightForFontInLabel:self.gradeLabel];
	self.gradeLabel.attributedText = [TRSViewCommons attributedGradeStringFromString:self.gradeLabel.text
																	  withBasePointSize:optimalSize
																			scaleFactor:1.0 / kTRSShopRatingViewGradingFontDifferenceRatio
																			 firstColor:[UIColor trs_black]
																			secondColor:[UIColor trs_80_gray]
																				font:self.gradeLabel.font];
	
	if (self.starsView) {
		self.starsView.frame = self.starPlaceholder.bounds;
	}
}

#pragma mark - Helper methods

// assumes aspect ratio of parent is correct
- (CGRect)frameForStars {
	CGRect starFrame = self.bounds;
	starFrame.size.height *= kTRSShopRatingViewStarsHeightToViewRatio;
	starFrame.size.width = starFrame.size.height * 5.0; // for 5 stars
	
	// figure out the x origin according to alignment
	NSTextAlignment myAlign = self.alignment;
	// first figure out what natural means, also treat justified in the same way!
	if (myAlign == NSTextAlignmentNatural || myAlign == NSTextAlignmentJustified) {
		if ([UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute]
			== UIUserInterfaceLayoutDirectionLeftToRight) {
			myAlign = NSTextAlignmentLeft;
		} else {
			myAlign = NSTextAlignmentRight;
		}
	}
	switch (myAlign) {
		case NSTextAlignmentLeft:
			starFrame.origin.x = 0.0;
			break;
		case NSTextAlignmentRight:
			starFrame.origin.x = self.frame.size.width - starFrame.size.width;
			break;
		default: // catches NSTextAligmentCenter, the other two are actually prevented above
			starFrame.origin.x = self.frame.size.width / 2.0 - starFrame.size.width / 2.0;
			break;
	}
	
	return starFrame;
}

// assumes aspect ratio of parent is correct
- (CGRect)frameForGradeLabel {
	CGRect gradeTextFrame = self.bounds;
	gradeTextFrame.size.height *= kTRSShopRatingViewGradeLabelHeightToViewRatio;
	gradeTextFrame.origin.y = self.frame.size.height - gradeTextFrame.size.height;
	
	return gradeTextFrame;
}

@end
