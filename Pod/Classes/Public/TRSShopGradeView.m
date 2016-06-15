//
//  TRSShopGradeView.m
//  Pods
//
//  Created by Gero Herkenrath on 13/06/16.
//

#import "TRSShopGradeView.h"
#import "TRSStarsView.h"
#import "UIColor+TRSColors.h"
#import "TRSViewCommons.h" // needed for some label width & font class methods

// minSize should be around {100.0, 60.0}, but that also depends on the text label (e.g. it's ~110 for "BEFRIEDIGEND")
CGFloat const kTRSShopGradingViewMinHeight = 60.0;
NSString *const kTRSShopGradingViewFontName = @"Arial"; //ensure this is on the system!
#define kTRSShopGradingViewStarsHeightToViewRatio (0.3)
#define kTRSShopGradingViewGradeAsTextHeightToViewRatio (0.3)
#define kTRSShopGradingViewGradeAsNumbersHeightToViewRatio (0.3)
#define kTRSShopGradingViewGradeAsNumbersFontDifferenceRatio (12.0 / 10.0)

@interface TRSShopGradeView ()

@property (nonatomic, strong) UIView *starPlaceholder;
@property (nonatomic, strong) TRSStarsView *starsView;
@property (nonatomic, strong) UILabel *gradeAsTextLabel;
@property (nonatomic, strong) UILabel *gradeAsNumbersLabel;

@end

@implementation TRSShopGradeView

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
	
	self.gradeAsTextLabel = [[UILabel alloc] initWithFrame:[self frameForGradeAsText]];
	self.gradeAsTextLabel.font = [UIFont fontWithName:kTRSShopGradingViewFontName size:self.gradeAsTextLabel.font.pointSize];
	self.gradeAsTextLabel.text = @"---";
//	self.gradeAsTextLabel.text = @"SEHR GUT";
	self.gradeAsTextLabel.textAlignment = NSTextAlignmentCenter;
	self.gradeAsTextLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:self.gradeAsTextLabel];
	
	self.gradeAsNumbersLabel = [[UILabel alloc] initWithFrame:[self frameForGradeAsNumbers]];
	self.gradeAsNumbersLabel.font = [UIFont fontWithName:kTRSShopGradingViewFontName size:self.gradeAsNumbersLabel.font.pointSize];
	self.gradeAsNumbersLabel.text = @"-.--/-.--";
//	self.gradeAsNumbersLabel.text = @"4.36/5.00";
	self.gradeAsNumbersLabel.textAlignment = NSTextAlignmentCenter;
	[self addSubview:self.gradeAsNumbersLabel];
}

#pragma mark - Loading data from TS Backend

- (void)loadShopGradeWithSuccessBlock:(void (^)(void))success failureBlock:(void (^)(NSError *error))failure {
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

- (void)loadShopGradeWithFailureBlock:(void (^)(NSError *error))failure {
	[self loadShopGradeWithSuccessBlock:nil failureBlock:failure];
}

#pragma mark - Custom setters for the colors

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
	if (size.height < kTRSShopGradingViewMinHeight) {
		size.height = kTRSShopGradingViewMinHeight;
	}
	CGFloat gradeTextLabelWidth = [TRSViewCommons widthForLabel:self.gradeAsTextLabel
													 withHeight:size.height * kTRSShopGradingViewGradeAsTextHeightToViewRatio];
	if (gradeTextLabelWidth < kTRSShopGradingViewMinHeight * kTRSShopGradingViewStarsHeightToViewRatio * 5.0) {
		gradeTextLabelWidth = kTRSShopGradingViewMinHeight * kTRSShopGradingViewStarsHeightToViewRatio * 5.0;
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
	self.gradeAsTextLabel.frame = [self frameForGradeAsText];
	self.gradeAsNumbersLabel.frame = [self frameForGradeAsNumbers];
	
	CGFloat optimalSize = [TRSViewCommons optimalHeightForFontInLabel:self.gradeAsTextLabel];
	self.gradeAsTextLabel.font = [self.gradeAsTextLabel.font fontWithSize:optimalSize];
	// for now just use a 2 point smaller font for the other label
	self.gradeAsNumbersLabel.attributedText = [TRSViewCommons attributedGradeStringFromString:self.gradeAsNumbersLabel.text
																			withBasePointSize:optimalSize - 2.0
																				  scaleFactor:1.0 / kTRSShopGradingViewGradeAsNumbersFontDifferenceRatio
																				   firstColor:[UIColor trs_black]
																				  secondColor:[UIColor trs_80_gray]
																						 font:self.gradeAsTextLabel.font];
	
	if (self.starsView) {
		self.starsView.frame = self.starPlaceholder.bounds;
	}
}

#pragma mark - Helper methods

// assumes aspect ratio of parent is correct
- (CGRect)frameForStars {
	CGRect starFrame = self.bounds;
	starFrame.size.height *= kTRSShopGradingViewStarsHeightToViewRatio;
	starFrame.size.width = starFrame.size.height * 5.0; // for 5 stars
	starFrame.origin.x = self.frame.size.width / 2.0 - starFrame.size.width / 2.0;
	return starFrame;
}

// assumes aspect ratio of parent is correct
- (CGRect)frameForGradeAsText {
	CGRect gradeTextFrame = self.bounds;
	gradeTextFrame.size.height *= kTRSShopGradingViewGradeAsTextHeightToViewRatio;
	gradeTextFrame.origin.y = self.frame.size.height / 2.0 - gradeTextFrame.size.height / 2.0;
	
	return gradeTextFrame;
}

// assumes aspect ratio of parent is correct
- (CGRect)frameForGradeAsNumbers {
	CGRect gradeNumbersFrame = self.bounds;
	gradeNumbersFrame.size.height *= kTRSShopGradingViewGradeAsNumbersHeightToViewRatio;
	gradeNumbersFrame.size.width = [TRSViewCommons widthForLabel:self.gradeAsNumbersLabel withHeight:gradeNumbersFrame.size.height];
	// don't allow smaller width than is used in a placeholder string
	UILabel *temp = [UILabel new];
	temp.text = @"-.--/-.--";
	CGFloat minWidth = [TRSViewCommons widthForLabel:temp withHeight:gradeNumbersFrame.size.height];
	if (gradeNumbersFrame.size.width < minWidth) {
		gradeNumbersFrame.size.width = minWidth;
	}
	gradeNumbersFrame.origin.x = self.frame.size.width / 2.0 - gradeNumbersFrame.size.width / 2.0;
	gradeNumbersFrame.origin.y = self.frame.size.height - gradeNumbersFrame.size.height;
	return gradeNumbersFrame;
}

@end
