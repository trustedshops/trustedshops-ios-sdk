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
#import "TRSErrors.h"
#import "TRSNetworkAgent+ShopGrade.h"
#import "NSNumberFormatter+TRSFormatter.h"
#import "TRSTrustbadgeSDKPrivate.h"
#import "NSURL+TRSURLExtensions.h"
#import "NSString+TRSStringOperations.h"

CGFloat const kTRSShopRatingViewMinHeight = 40.0;
NSString *const kTRSShopRatingViewFontName = @"Arial"; // ensure this is on the system!
#define kTRSShopRatingViewStarsHeightToViewRatio (0.5)
#define kTRSShopRatingViewGradeLabelHeightToViewRatio (0.4)
#define kTRSShopRatingViewGradingFontDifferenceRatio (12.0 / 10.0)

// constants used for encoding and decoding
NSString *const kTRSShopRatingViewActiveStarColorKey = @"kTRSShopRatingViewActiveStarColorKey";
NSString *const kTRSShopRatingViewInactiveStarColorKey = @"kTRSShopRatingViewInactiveStarColorKey";
NSString *const kTRSShopRatingViewAlignmentKey = @"kTRSShopRatingViewAlignmentKey";
NSString *const kTRSShopRatingViewTSIDKey = @"kTRSShopRatingViewTSIDKey";
NSString *const kTRSShopRatingViewApiTokenKey = @"kTRSShopRatingViewApiTokenKey";
NSString *const kTRSShopRatingViewDebugModeKey = @"kTRSShopRatingViewDebugModeKey";

@interface TRSShopRatingView ()

@property (nonatomic, strong) UIView *starPlaceholder;
@property (nonatomic, strong) TRSStarsView *starsView;
@property (nonatomic, strong) UILabel *gradeLabel;

@property (nonatomic, strong) NSNumber *gradeNumber;
@property (nonatomic, strong) NSNumber *reviewCount;
@property (nonatomic, copy) NSString *gradeText; // atm this not actually displayed in the view
@property (nonatomic, copy) NSString *targetMarketISO3;
@property (nonatomic, copy) NSString *languageISO2;

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
		_activeStarColor = [coder decodeObjectForKey:kTRSShopRatingViewActiveStarColorKey];
		_inactiveStarColor = [coder decodeObjectForKey:kTRSShopRatingViewInactiveStarColorKey];
		_alignment = [coder decodeIntegerForKey:kTRSShopRatingViewAlignmentKey];
		_tsID = [coder decodeObjectForKey:kTRSShopRatingViewTSIDKey];
		_apiToken = [coder decodeObjectForKey:kTRSShopRatingViewApiTokenKey];
		_debugMode = [coder decodeBoolForKey:kTRSShopRatingViewDebugModeKey];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:self.activeStarColor forKey:kTRSShopRatingViewActiveStarColorKey];
	[aCoder encodeObject:self.inactiveStarColor forKey:kTRSShopRatingViewInactiveStarColorKey];
	[aCoder encodeInteger:self.alignment forKey:kTRSShopRatingViewAlignmentKey];
	[aCoder encodeObject:self.tsID forKey:kTRSShopRatingViewTSIDKey];
	[aCoder encodeObject:self.apiToken forKey:kTRSShopRatingViewApiTokenKey];
	[aCoder encodeBool:self.debugMode forKey:kTRSShopRatingViewDebugModeKey];
}

- (void)finishInit {
	_activeStarColor = [UIColor trs_filledStarColor];
	_inactiveStarColor = [UIColor trs_nonFilledStarColor];
	
	_alignment = NSTextAlignmentNatural;
	
	[self sizeToFit];
	
	_starPlaceholder = [[UIView alloc] initWithFrame:[self frameForStars]];
	_starPlaceholder.backgroundColor = [UIColor clearColor];
	[self addSubview:_starPlaceholder];
	
	_gradeLabel = [[UILabel alloc] initWithFrame:[self frameForGradeLabel]];
	_gradeLabel.backgroundColor = [UIColor clearColor];
	_gradeLabel.font = [UIFont fontWithName:kTRSShopRatingViewFontName size:_gradeLabel.font.pointSize]; // size irrelevant
	_gradeLabel.text = @"-.--/-.-- (----)";
	_gradeLabel.textAlignment = _alignment;
	[self addSubview:_gradeLabel];
	
}

#pragma mark - Loading data from TS Backend

- (void)loadShopRatingWithSuccessBlock:(void (^)(void))success failureBlock:(void (^)(NSError *error))failure {
	
	if (!self.tsID || !self.apiToken) {
		if (failure) {
			NSError *notReady = [NSError errorWithDomain:TRSErrorDomain
													code:TRSErrorDomainMissingTSIDOrAPIToken
												userInfo:nil];
			failure(notReady);
			return;
		}
	}
	
	// ensure the agent has the correct debugMode flag
	[TRSNetworkAgent sharedAgent].debugMode = self.debugMode;
	
	[[TRSNetworkAgent sharedAgent] getShopGradeForTrustedShopsID:self.tsID apiToken:self.apiToken success:^(NSDictionary *gradeData) {
		
		self.gradeText = [gradeData[@"overallMarkDescription"] readableMarkDescription];
		self.gradeNumber = gradeData[@"overallMark"];
		self.reviewCount = gradeData[@"activeReviewCount"];
		self.targetMarketISO3 = gradeData[@"targetMarketISO3"];
		self.languageISO2 = gradeData[@"languageISO2"];
		
		// note (dirty cheat): due to the rendering chain it's important to do this asynchronously, otherwise
		// we might get the wrong frame for this. Once it loads from the backend that's not to important,
		// but if the request is e.g. cached, it might screw us.
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			self.starsView = [[TRSStarsView alloc] initWithFrame:self.starPlaceholder.bounds rating:self.gradeNumber];
			self.starsView.activeStarColor = _activeStarColor;
			self.starsView.inactiveStarColor = _inactiveStarColor;
			[self.starPlaceholder addSubview:self.starsView];
			if (success) {
				success();
			}
		});
	} failure:^(NSError *error) {
		if (![error.domain isEqualToString:TRSErrorDomain]) {
			if (failure) failure(error);
			return;
		}
		switch (error.code) {
			case TRSErrorDomainInvalidAPIToken:
				NSLog(@"[trustbadge] The provided API token is not correct");
				break;
				
			case TRSErrorDomainInvalidTSID:
				NSLog(@"[trustbadge] The provided TSID is not correct.");
				break;
				
			case TRSErrorDomainTSIDNotFound:
				NSLog(@"[trustbadge] The provided TSID could not be found.");
				break;
				
			case TRSErrorDomainInvalidData:
				NSLog(@"[trustbadge] The received data is corrupt.");
				break;
				
			case TRSErrorDomainUnknownError:
			default:
				NSLog(@"[trustbadge] An unkown error occured.");
				break;
		}
		
		// we give back the error even if we could pre-handle it here
		if (failure) failure(error);
	}];
}

- (void)loadShopRatingWithFailureBlock:(void (^)(NSError *error))failure {
	[self loadShopRatingWithSuccessBlock:nil failureBlock:failure];
}

#pragma mark - Touch detection

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	if (!self.starsView) {
		[super touchesBegan:touches withEvent:event];
	}
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	if (!self.starsView) {
		[super touchesBegan:touches withEvent:event];
	}
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	if (!self.starsView) {
		[super touchesBegan:touches withEvent:event];
	} else {
		NSURL *targetURL = [NSURL profileURLForTSID:self.tsID countryCode:self.targetMarketISO3 language:self.languageISO2];
		[[UIApplication sharedApplication] openURL:targetURL];
	}
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	if (!self.starsView) {
		[super touchesBegan:touches withEvent:event];
	}
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
	NSString *unit;
	if (self.reviewCount.unsignedIntegerValue != 1) {
		unit = TRSLocalizedString(@"Reviews", @"Used in the shop grading views' grade label (plural)") ;
	} else {
		unit = TRSLocalizedString(@"Review", @"Used in the shop grading views' grade label (singular)") ;
	}
	self.gradeLabel.text = [NSString stringWithFormat:@"%@ (%@ %@)", [self gradeNumberString], [self reviewCount], unit];
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

- (NSString *)gradeNumberString {
	NSNumberFormatter *trsFormatter = [NSNumberFormatter trs_trustbadgeRatingFormatter];
	NSString *first = [trsFormatter stringFromNumber:self.gradeNumber];
	NSString *second = [trsFormatter stringFromNumber:@5];
	return [NSString stringWithFormat:@"%@/%@", first, second];
}

- (NSString *)reviewCountString {
	return [[NSNumberFormatter trs_reviewCountFormatter] stringFromNumber:self.reviewCount];
}

@end
