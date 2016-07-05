//
//  TRSProductRatingView.m
//  Pods
//
//  Created by Gero Herkenrath on 05/07/16.
//
//

#import "TRSProductRatingView.h"
#import "TRSViewCommons.h"
#import "TRSStarsView.h"

// import private headers so we can access methods and properties
#import "TRSPrivateBasicDataView+Private.h"
#import "TRSProductBaseView+Private.h"

// private constants
CGFloat const kTRSProductRatingViewMinHeight = 20.0; // using half of this if useOnlyOneLine is YES
CGFloat const kTRSProductRatingViewStarsHeightToViewRatio = 0.5; // not used if useOnlyOneLine is YES
CGFloat const kTRSProductRatingViewLabelsHeightToViewRatio = 0.4; // doubled if useOnlyOneLine is YES
CGFloat const kTRSProductRatingViewGradingFontDifferenceRatio = (12.0 / 10.0);
NSString *const kTRSProductRatingViewFontName = @"Arial";
NSString *const kTRSProductRatingViewUseOnlyOneLineKey = @"kTRSProductRatingViewUseOnlyOneLineKey";

@interface TRSProductRatingView ()

@property (nonatomic, strong) UILabel *gradeLabel;

@end

@implementation TRSProductRatingView

#pragma mark - initWithCoder & encodeWithCoder additions

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder]; // this also calls finishInit!
	if (self) {
		self.useOnlyOneLine = [aDecoder decodeBoolForKey:kTRSProductRatingViewUseOnlyOneLineKey];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeBool:self.useOnlyOneLine forKey:kTRSProductRatingViewUseOnlyOneLineKey];
}

#pragma mark - Resizing behavior (min size)

- (CGFloat)minHeight {
	if (self.useOnlyOneLine) {
		return kTRSProductRatingViewMinHeight / 2.0;
	} else {
		return kTRSProductRatingViewMinHeight;
	}
}

- (CGFloat)labelHeightRatio {
	if (self.useOnlyOneLine) {
		return 2.0 * kTRSProductRatingViewLabelsHeightToViewRatio;
	} else {
		return kTRSProductRatingViewLabelsHeightToViewRatio;
	}
}

- (CGSize)sizeThatFits:(CGSize)size {
	// TODO: finish that later...
	
	if (size.height < self.minHeight) { // if wanted height too small: increase it to min
		size.height = self.minHeight;
	}
	CGFloat gradeTextLabelWidth = [TRSViewCommons widthForLabel:self.gradeLabel
														withHeight:size.height * [self labelHeightRatio]
												optimalFontSize:NULL
										 smallerCharactersScale:1.0 / kTRSProductRatingViewGradingFontDifferenceRatio];
	CGFloat minFirstLineWidth = self.minHeight * kTRSStarsViewNumberOfStars;
	if (self.useOnlyOneLine) { // one line? -> add to minwidth
		minFirstLineWidth += gradeTextLabelWidth;
	} else if (minFirstLineWidth < gradeTextLabelWidth) { // two lines? -> chose bigger one as minwodth
		minFirstLineWidth = gradeTextLabelWidth;
	}
	if (size.width < minFirstLineWidth) { // if wanted width too small: increase it to min
		size.width = minFirstLineWidth;
	}
	return size;
}

#pragma mark - Drawing

- (void)layoutSubviews {
	[super layoutSubviews]; // calls sizeToFit
	self.gradeLabel.frame = [self frameForGrade];
}

#pragma mark - Helper methods

// assumes aspect ratio of parent is correct
- (CGRect)frameForStars {
	CGSize mySize = self.frame.size;
	CGFloat lengthPerStar = self.useOnlyOneLine ? mySize.height : mySize.height * kTRSProductRatingViewStarsHeightToViewRatio;
	// TODO: work out alignment!
	CGRect theFrame = CGRectMake(0.0, 0.0, lengthPerStar * kTRSStarsViewNumberOfStars, lengthPerStar);
	return theFrame;
}

- (CGRect)frameForGrade {
	CGRect myFrame = self.bounds;
	myFrame.size.height *= [self labelHeightRatio];
	myFrame.origin.y += self.bounds.size.height - myFrame.size.height;
	// TODO: work out alignment!
	myFrame.origin.x += self.useOnlyOneLine ? [self frameForStars].size.width : 0.0;
	return myFrame;
}

#pragma mark - Methods to override defined by private TRSPrivateBasicDataView

- (void)finishInit {
	[super finishInit]; // can use super in this case, inits starsPlaceholder
	self.useOnlyOneLine = NO;
	self.gradeLabel = [[UILabel alloc] initWithFrame:[self frameForGrade]];
	self.gradeLabel.backgroundColor = [UIColor clearColor];
	self.gradeLabel.font = [UIFont fontWithName:kTRSProductRatingViewFontName size:self.gradeLabel.font.pointSize]; // size irrelevant
	self.gradeLabel.text = @"-.--/-.-- (----)";
	[self addSubview:self.gradeLabel];
}

- (void)finishLoading {
	[super finishLoading]; // can use super in this case
	
	// set up the label strings here (best in properties, so they don't get reconstructed in every call of layoutSubviews
}

@end
