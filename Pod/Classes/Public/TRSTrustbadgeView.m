#import "TRSTrustbadgeView.h"
#import "NSNumberFormatter+TRSFormatter.h"
#import "TRSErrors.h"
#import "TRSNetworkAgent+Trustbadge.h"
#import "TRSRatingView.h"
#import "TRSTrustbadge.h"
#import "TRSTrustbadgeSDKPrivate.h"
#import "UIColor+TRSColors.h"


@interface TRSTrustbadgeView ()

@property (nonatomic, copy, readwrite) NSString *trustedShopsID;
@property (nonatomic, copy, readwrite) NSString *apiToken;
@property (nonatomic, strong) UIImageView *sealImageView;
@property (nonatomic, strong) UILabel *offlineMarker;
@property (nonatomic, assign) BOOL hasSealStateChangePending;
@property (nonatomic, strong) TRSTrustbadge *trustbadge;

// needed for xib loading (don't be confused about two designated initializers...)
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

@implementation TRSTrustbadgeView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)aRect
			   TrustedShopsID:(NSString *)trustedShopsID
					 apiToken:(NSString *)apiToken {
	
	self = [super initWithFrame:aRect];
	if (!self) {
		return nil;
	}
	
	[self finishInit:trustedShopsID apiToken:apiToken];
	
	return self;
}

- (instancetype)initWithTrustedShopsID:(NSString *)trustedShopsID {
	return [self initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 64.0f) TrustedShopsID:nil apiToken:nil];
}

- (instancetype)initWithTrustedShopsID:(NSString *)trustedShopsID apiToken:(NSString *)apiToken {
	return [self initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 64.0f) TrustedShopsID:trustedShopsID apiToken:apiToken];
}

// properly overwrite the designated initializers of the superclass
- (instancetype)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame TrustedShopsID:nil apiToken:nil];
}

- (instancetype)init
{
	return [self initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 64.0f)];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	
	self = [super initWithCoder:aDecoder];
	if (!self) {
		return nil;
	}
	
	[self finishInit:nil apiToken:nil]; // when being loaded from a xib, we won't have these (for now)
	
	return self;
}

- (instancetype)finishInit:(NSString *)trustedShopsID apiToken:(NSString *)apiToken {
	
	// first get the image, we'll need that in any case:
	UIImage *sealImage = [UIImage imageWithContentsOfFile:
						  [TRSTrustbadgeBundle() pathForResource:@"iOS-SDK-Seal" ofType:@"png"]];
	self.sealImageView = [[UIImageView alloc] initWithImage:sealImage];
	[self addSubview:self.sealImageView];
	// also set the offline marker label view, but then make it invisible
	self.offlineMarker = [[UILabel alloc] init];
	self.offlineMarker.text = @"OFFLINE";
	[self.offlineMarker setFrame:self.sealImageView.frame];
	[self.offlineMarker setTextAlignment:NSTextAlignmentCenter];
	[self.offlineMarker setAdjustsFontSizeToFitWidth:YES];
	[self.offlineMarker setHidden:YES];
	[self addSubview:self.offlineMarker];
	
	// next save our id and token. this will also determine if we show an "offline" label or something over the seal
	_trustedShopsID = [trustedShopsID copy];
	_apiToken = [apiToken copy];
	
	// TODO: Check whether this really needs to be delayed (to avoid it flashing up even if the data is loaded immediately)
	[self displaySealAsOffline:YES afterDelay:1.0];

	return self;
}

#pragma mark - Getting certificate & shop data from remote API

- (void)loadTrustbadgeWithSuccessBlock:(void (^)(void))success failureBlock:(void (^)(NSError *error))failure {
	void (^wins)(TRSTrustbadge *theTrustbadge) = ^(TRSTrustbadge *theTrustbadge) {
		[self displaySealAsOffline:NO afterDelay:0.0];
		
		self.trustbadge = theTrustbadge;
		
		if (success) { // don't these lines look kinda sick? shifting brackets... :)
			success();
		}
	};
	
	void (^fails)(NSError *error) = ^(NSError *error) {
		if (![error.domain isEqualToString:TRSErrorDomain]) {
			if (failure) failure(error);
			return;
		}
		switch (error.code) {
			case TRSErrorDomainTrustbadgeInvalidAPIToken:
				NSLog(@"[trustbadge] The provided API token is not correct");
				break;
				
			case TRSErrorDomainTrustbadgeInvalidTSID:
				NSLog(@"[trustbadge] The provided TSID is not correct.");
				break;
				
			case TRSErrorDomainTrustbadgeTSIDNotFound:
				NSLog(@"[trustbadge] The provided TSID could not be found.");
				break;
				
			case TRSErrorDomainTrustbadgeInvalidData:
				NSLog(@"[trustbadge] The received data is corrupt.");
				break;
				
			case TRSErrorDomainTrustbadgeUnknownError:
			default:
				NSLog(@"[trustbadge] An unkown error occured.");
				break;
		}
		
		// we give back the error even if we could pre-handle it here
		if (failure) failure(error);
	};
	
	if (!self.apiToken || !self.trustedShopsID) {
		NSError *myError = [NSError errorWithDomain:TRSErrorDomain
											   code:TRSErrorDomainTrustbadgeMissingTSIDOrAPIToken
										   userInfo:nil];
		NSLog(@"[trustbadge] There is no API token or TSID provided to contact the API.");
		if (failure) failure(myError);
	}
	
	// the returned task is not important for now...
	[[TRSNetworkAgent sharedAgent] getTrustbadgeForTrustedShopsID:_trustedShopsID
														 apiToken:_apiToken
														  success:wins
														  failure:fails];

}

- (void)loadTrustbadgeWithFailureBlock:(void (^)(NSError *error))failure {
	[self loadTrustbadgeWithSuccessBlock:nil failureBlock:failure];
}

#pragma mark - Helper

// This one deserves a little explanation:
// Basically we have two modes this method can operate like:
// 1: Immedietaly set the seal to OFFLINE of ONLINE
// 2: Do so after a delay.
// The problem is that if we set a delayed switch, this can "swallow" an immediate one.
// Let's say we start by showing the seal ONLINE in good faith and configure it to go offline after a second to
// give the calling app code time to call loadTrustbadgeWithFailureBlock: and thus properly activate the badge.
// Once it does that, the seal is immediately set to ONLINE (even though it already IS in that state). But then
// the delayed switch to OFFLINE undoes that.
// This method prioritizes immediate changes to prevent that. It does so by basically disallowing ALL pending
// state changes each time an immediate change is ordered.
- (void)displaySealAsOffline:(BOOL)offline afterDelay:(NSTimeInterval)seconds {
	// prepare a block
	void (^changeIt)(BOOL off, BOOL wasDelayed) = ^(BOOL off, BOOL wasDelayed) {
		if (wasDelayed && !self.hasSealStateChangePending) {
			return;
		}
		if (off) {
			[self.sealImageView setAlpha:0.3f];
			[self.offlineMarker setHidden:NO];
		} else {
			[self.sealImageView setAlpha:1.0f];
			[self.offlineMarker setHidden:YES];
		}
		[self setNeedsDisplay];
	};
	
	if (seconds == 0.0) {
		self.hasSealStateChangePending = NO;
		changeIt(offline, NO);
	} else {
		self.hasSealStateChangePending = YES;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			changeIt(offline, YES);
		});
	}
}

@end
