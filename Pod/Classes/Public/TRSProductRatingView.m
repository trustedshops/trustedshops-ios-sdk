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
#import "UIColor+TRSColors.h"

// import private headers so we can access methods and properties
#import "TRSPrivateBasicDataView+Private.h"
#import "TRSProductBaseView+Private.h"
#import "TRSTrustbadgeSDKPrivate.h"

// private constants
CGFloat const kTRSProductRatingViewMinHeight = 20.0; // using half of this if useOnlyOneLine is YES
CGFloat const kTRSProductRatingViewStarsHeightToViewRatio = 0.5; // not used if useOnlyOneLine is YES
CGFloat const kTRSProductRatingViewLabelsHeightToViewRatio = 0.4; // doubled if useOnlyOneLine is YES
CGFloat const kTRSProductRatingViewGradingFontDifferenceRatio = (12.0 / 10.0);
NSString *const kTRSProductRatingViewFontName = @"Arial";
NSString *const kTRSProductRatingViewUseOnlyOneLineKey = @"kTRSProductRatingViewUseOnlyOneLineKey";

@interface TRSProductRatingView ()

@property (nonatomic, strong) UILabel *gradeLabel;

// these are just used to keep both versions of the grade string around and inited in finishLoading
@property (nonatomic, copy) NSString *oneLineString;
@property (nonatomic, copy) NSString *twoLineString;

@end

@implementation TRSProductRatingView

#pragma mark - initWithCoder & encodeWithCoder additions

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder]; // this also calls finishInit!
	if (self) {
		_useOnlyOneLine = [aDecoder decodeBoolForKey:kTRSProductRatingViewUseOnlyOneLineKey];
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
	if (size.height < self.minHeight) { // if wanted height too small: increase it to min
		size.height = self.minHeight;
	}
	// don't use scaled fonts if in one line
	CGFloat scaleFactor = self.useOnlyOneLine ? 1.0 : (1.0 / kTRSProductRatingViewGradingFontDifferenceRatio);
	CGFloat gradeTextLabelWidth = [TRSViewCommons widthForLabel:self.gradeLabel
														withHeight:size.height * [self labelHeightRatio]
												optimalFontSize:NULL
										 smallerCharactersScale:scaleFactor];
	CGFloat minFirstLineWidth = self.minHeight * kTRSStarsViewNumberOfStars;
	if (self.useOnlyOneLine) { // one line? -> add to minwidth
		minFirstLineWidth += gradeTextLabelWidth;
	} else if (minFirstLineWidth < gradeTextLabelWidth) { // two lines? -> chose bigger one as minwidth
		minFirstLineWidth = gradeTextLabelWidth;
	}
	if (size.width < minFirstLineWidth) { // if wanted width too small: increase it to min
		size.width = minFirstLineWidth;
	}
	return size;
}

#pragma mark - Drawing

- (void)layoutSubviews {
	// it's important we prepare the text of the label beforehand, otherwise the layout calculation in super won't
	// work (it calls sizeToFit, which is overridden here and needs the labels text to calculate dimensions).
	self.gradeLabel.text = self.useOnlyOneLine ? self.oneLineString : self.twoLineString;
	[super layoutSubviews]; // calls sizeToFit
	self.gradeLabel.frame = [self frameForGrade];
	CGFloat optimalPointSize = [TRSViewCommons optimalHeightForFontInLabel:self.gradeLabel];
	CGFloat scaleFactor = 1.0 / kTRSProductRatingViewGradingFontDifferenceRatio; // only used for two lines
	if (self.useOnlyOneLine) {
		self.gradeLabel.attributedText = [self attributedOneLineStringWithPointSize:optimalPointSize];
	} else {
		self.gradeLabel.attributedText = [TRSViewCommons attributedGradeStringFromString:self.twoLineString
																	   withBasePointSize:optimalPointSize
																			 scaleFactor:scaleFactor
																			  firstColor:[UIColor trs_black]
																			 secondColor:[UIColor trs_80_gray]
																					font:self.gradeLabel.font];
	}
}

#pragma mark - Custom setters

- (void)setUseOnlyOneLine:(BOOL)useOnlyOneLine {
	if (useOnlyOneLine != _useOnlyOneLine) {
		_useOnlyOneLine = useOnlyOneLine;
		if (useOnlyOneLine) {
			// in one line mode, the text in the label is always centered! (actual alignment of the label is defined
			// by its frame, centering the text in that prevents "jittering").
			self.gradeLabel.textAlignment = NSTextAlignmentCenter;
		} else {
			self.gradeLabel.textAlignment = _alignment;
		}
		[self setNeedsLayout];
	}
}

- (void)setAlignment:(NSTextAlignment)alignment {
	if (alignment != _alignment) {
		_alignment = alignment;
		if (!self.useOnlyOneLine) {
			self.gradeLabel.textAlignment = _alignment;
		}
		[self setNeedsLayout];
	}
}

#pragma mark - Helper methods

// assumes aspect ratio of parent is correct
- (CGRect)frameForStars {
	CGSize mySize = self.frame.size;
	CGFloat lengthPerStar = self.useOnlyOneLine ? mySize.height : mySize.height * kTRSProductRatingViewStarsHeightToViewRatio;
	CGRect theFrame = CGRectMake(0.0, 0.0, lengthPerStar * kTRSStarsViewNumberOfStars, lengthPerStar);
	
	CGFloat labelHeight = mySize.height * [self labelHeightRatio];
	CGFloat offsetDueToLabel = self.useOnlyOneLine ? [TRSViewCommons widthForLabel:self.gradeLabel withHeight:labelHeight] : 0.0;
	
	switch ([self actualAlignment]) {
		case NSTextAlignmentLeft:
			theFrame.origin.x = 0.0;
			break;
		case NSTextAlignmentRight:
			theFrame.origin.x = self.frame.size.width - theFrame.size.width - offsetDueToLabel;
			break;
		default: // catches NSTextAligmentCenter, the other two are actually prevented in actualAlignment
			theFrame.origin.x = self.frame.size.width / 2.0 - theFrame.size.width / 2.0 - offsetDueToLabel / 2.0;
			break;
	}

	return theFrame;
}

- (CGRect)frameForGrade {
	CGRect myFrame = self.bounds;
	CGFloat lengthPerStar = self.useOnlyOneLine ? myFrame.size.height : myFrame.size.height * kTRSProductRatingViewStarsHeightToViewRatio;
	myFrame.size.height *= [self labelHeightRatio];
	myFrame.size.width = [TRSViewCommons widthForLabel:self.gradeLabel withHeight:myFrame.size.height];
	myFrame.origin.y += self.bounds.size.height - myFrame.size.height;
	
	CGFloat offsetDueToStars = self.useOnlyOneLine ? lengthPerStar * kTRSStarsViewNumberOfStars : 0.0;
	
	switch ([self actualAlignment]) {
		case NSTextAlignmentLeft:
			myFrame.origin.x = 0.0 + offsetDueToStars;
			break;
		case NSTextAlignmentRight:
			myFrame.origin.x = self.bounds.size.width - myFrame.size.width;
			break;
		default: // catches NSTextAligmentCenter, the other two are actually prevented in actualAlignment
			myFrame.origin.x = self.bounds.size.width / 2.0 - myFrame.size.width / 2.0 + offsetDueToStars / 2.0;
			break;
	}
	
	return myFrame;
}

- (NSAttributedString *)attributedOneLineStringWithPointSize:(CGFloat)size {
	
	NSAttributedString *retVal = nil;
	// safety check:
	if (self.oneLineString.length >= 13) { // somehow we have the wrong string, do nothing
		// note: the string can't be shorter than 13: @"(0) 0.00/5.00" (no reviews, zero grade) ->
		NSUInteger indexMiddlePart = self.oneLineString.length - 9;
		NSUInteger indexLastPart = self.oneLineString.length - 5;
		
		NSString *firstRaw = [self.oneLineString substringToIndex:indexMiddlePart];
		NSString *middleRaw = [self.oneLineString substringWithRange:NSMakeRange(indexMiddlePart, 4)];
		NSString *lastRaw = [self.oneLineString substringFromIndex:indexLastPart];
		
		NSDictionary *greyColor = @{NSFontAttributeName : [UIFont fontWithName:kTRSProductRatingViewFontName size:size],
									NSForegroundColorAttributeName : [UIColor trs_80_gray]};
		NSDictionary *blackColor = @{NSFontAttributeName : [UIFont fontWithName:kTRSProductRatingViewFontName size:size],
									 NSForegroundColorAttributeName : [UIColor trs_black]};
		NSMutableAttributedString *firstPart = [[NSMutableAttributedString alloc] initWithString:firstRaw attributes:greyColor];
		NSAttributedString *middlePart = [[NSMutableAttributedString alloc] initWithString:middleRaw attributes:blackColor];
		NSAttributedString *lastPart = [[NSMutableAttributedString alloc] initWithString:lastRaw attributes:greyColor];
		
		[firstPart appendAttributedString:middlePart];
		[firstPart appendAttributedString:lastPart];
		
		retVal = [[NSAttributedString alloc] initWithAttributedString:firstPart];
	}
	return retVal;
}

- (NSTextAlignment)actualAlignment {
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
	return myAlign;
}

#pragma mark - Methods to override defined by TRSPrivateBasicDataView

- (void)finishInit {
	[super finishInit]; // can use super in this case, inits starsPlaceholder
	_useOnlyOneLine = NO;
	_alignment = NSTextAlignmentNatural;
	
	_oneLineString = @"(-) -.--/-.--";
	_twoLineString = @"-.--/-.-- (----)";
	_gradeLabel = [[UILabel alloc] initWithFrame:[self frameForGrade]];
	_gradeLabel.backgroundColor = [UIColor clearColor];
	// we don't need a default value for the label, that's done in layoutSubviews
	[self addSubview:_gradeLabel];
}

- (void)finishLoading {
	[super finishLoading]; // can use super in this case
	
	// set up the label strings here (best in properties, so they don't get reconstructed in every call of layoutSubviews
	NSString *unit;
	if (self.totalReviewCount.unsignedIntegerValue > 1) {
		unit = TRSLocalizedString(@"Reviews", @"Used in the shop grading views' grade label (plural)") ;
	} else {
		unit = TRSLocalizedString(@"Review", @"Used in the shop grading views' grade label (singular)") ;
	}
	self.twoLineString = [NSString stringWithFormat:@"%@ (%@ %@)",
						  [TRSViewCommons gradeStringForNumber:self.overallMark],
						  [TRSViewCommons reviewCountStringForNumber:self.totalReviewCount], unit];
	self.oneLineString = [NSString stringWithFormat:@"(%@) %@",
						  [TRSViewCommons reviewCountStringForNumber:self.totalReviewCount],
						  [TRSViewCommons gradeStringForNumber:self.overallMark]];
}

@end
