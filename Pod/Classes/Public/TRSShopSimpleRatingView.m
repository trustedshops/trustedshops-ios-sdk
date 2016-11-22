//
//  TRSShopSimpleRatingView.m
//  Pods
//
//  Created by Gero Herkenrath on 14/06/16.
//

#import "TRSShopSimpleRatingView.h"
#import "TRSStarsView.h"
#import "UIColor+TRSColors.h"
#import "TRSErrors.h"
#import "TRSNetworkAgent+ShopGrade.h"
#import "NSURL+TRSURLExtensions.h"
#import "TRSSingleStarView.h" // only needed to see its constant for min height

CGFloat const kTRSShopSimpleRatingViewMinHeight = 16.0; // should not be smaller than kTRSSingleStarViewMinHeight
NSString *const kTRSShopSimpleRatingViewActiveStarColorKey = @"kTRSShopSimpleRatingViewActiveStarColorKey";
NSString *const kTRSShopSimpleRatingViewInactiveStarColorKey = @"kTRSShopSimpleRatingViewInactiveStarColorKey";
NSString *const kTRSShopSimpleRatingViewTSIDKey = @"kTRSShopSimpleRatingViewTSIDKey";
NSString *const kTRSShopSimpleRatingViewApiTokenKey = @"kTRSShopSimpleRatingViewApiTokenKey";
NSString *const kTRSShopSimpleRatingViewDebugModeKey = @"kTRSShopSimpleRatingViewDebugModeKey";

@interface TRSShopSimpleRatingView ()

@property (nonatomic, strong) UIView *starPlaceholder;
@property (nonatomic, strong) TRSStarsView * starsView;

@property (nonatomic, strong) NSNumber *gradeNumber;
@property (nonatomic, copy) NSString *targetMarketISO3;
@property (nonatomic, copy) NSString *languageISO2;

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
		_activeStarColor = [coder decodeObjectForKey:kTRSShopSimpleRatingViewActiveStarColorKey];
		_inactiveStarColor = [coder decodeObjectForKey:kTRSShopSimpleRatingViewInactiveStarColorKey];
		_tsID = [coder decodeObjectForKey:kTRSShopSimpleRatingViewTSIDKey];
		_apiToken = [coder decodeObjectForKey:kTRSShopSimpleRatingViewApiTokenKey];
		_debugMode = [coder decodeBoolForKey:kTRSShopSimpleRatingViewDebugModeKey];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:self.activeStarColor forKey:kTRSShopSimpleRatingViewActiveStarColorKey];
	[aCoder encodeObject:self.inactiveStarColor forKey:kTRSShopSimpleRatingViewInactiveStarColorKey];
	[aCoder encodeObject:self.tsID forKey:kTRSShopSimpleRatingViewTSIDKey];
	[aCoder encodeObject:self.apiToken forKey:kTRSShopSimpleRatingViewApiTokenKey];
	[aCoder encodeBool:self.debugMode forKey:kTRSShopSimpleRatingViewDebugModeKey];
}

- (void)finishInit {
	_activeStarColor = [UIColor trs_filledStarColor];
	_inactiveStarColor = [UIColor trs_nonFilledStarColor];
	
	[self sizeToFit];
	
	_starPlaceholder = [[UIView alloc] initWithFrame:[self frameForStars]];
	_starPlaceholder.backgroundColor = [UIColor clearColor];
	[self addSubview:_starPlaceholder];
	
}

#pragma mark - Loading data from TS Backend

- (void)loadShopSimpleRatingWithSuccessBlock:(void (^)(void))success failureBlock:(void (^)(NSError *error))failure {
	
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
		
		self.gradeNumber = gradeData[@"overallMark"];
		self.targetMarketISO3 = gradeData[@"targetMarketISO3"];
		self.languageISO2 = gradeData[@"languageISO2"];
		
		// note (dirty cheat): due to the rendering chain it's important to do this asynchronously, otherwise
		// we might get the wrong frame for this. Once it loads from the backend that's not too important,
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
				
//			case TRSErrorDomainUnknownError: // already caught in default
			default:
				NSLog(@"[trustbadge] An unkown error occured.");
				break;
		}
		
		// we give back the error even if we could pre-handle it here
		if (failure) failure(error);
	}];
}

- (void)loadShopSimpleRatingWithFailureBlock:(void (^)(NSError *error))failure {
	[self loadShopSimpleRatingWithSuccessBlock:nil failureBlock:failure];
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

#pragma mark - Resizing behavior (min size)

- (CGSize)sizeThatFits:(CGSize)size {
	CGFloat myMin = MAX(kTRSSingleStarViewMinHeight, kTRSShopSimpleRatingViewMinHeight);
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
