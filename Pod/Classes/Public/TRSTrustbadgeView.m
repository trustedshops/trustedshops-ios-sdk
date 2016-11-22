#import "TRSTrustbadgeView.h"
#import "TRSErrors.h"
#import "TRSNetworkAgent+Trustbadge.h"
#import "TRSTrustbadge.h"
#import "TRSTrustbadgeSDKPrivate.h"


@interface TRSTrustbadgeView ()

@property (nonatomic, copy, readwrite) NSString *trustedShopsID;
@property (nonatomic, copy, readwrite) NSString *apiToken;
@property (nonatomic, strong) UIImageView *sealImageView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *offlineMarker;
@property (nonatomic, assign) BOOL hasSealStateChangePending;
@property (nonatomic, strong) TRSTrustbadge *trustbadge;

// needed for xib loading (don't be confused about two designated initializers...)
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

@implementation TRSTrustbadgeView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)aRect
			   trustedShopsID:(NSString *)trustedShopsID
					 apiToken:(NSString *)apiToken {
	
	self = [super initWithFrame:aRect];
	if (self) {
		[self finishInit:trustedShopsID apiToken:apiToken];
	}
	
	return self;
}

- (instancetype)initWithTrustedShopsID:(NSString *)trustedShopsID {
	return [self initWithFrame:CGRectMake(0.0, 0.0, 64.0, 64.0) trustedShopsID:trustedShopsID apiToken:nil];
}

- (instancetype)initWithTrustedShopsID:(NSString *)trustedShopsID apiToken:(NSString *)apiToken {
	return [self initWithFrame:CGRectMake(0.0, 0.0, 64.0, 64.0) trustedShopsID:trustedShopsID apiToken:apiToken];
}

// properly overwrite the designated initializers of the superclass
- (instancetype)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame trustedShopsID:nil apiToken:nil];
}

- (instancetype)init
{
	return [self initWithFrame:CGRectMake(0.0, 0.0, 64.0, 64.0)];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self finishInit:nil apiToken:nil]; // when being loaded from a xib, we won't have these (for now)
	}
	return self;
}

- (void)finishInit:(NSString *)trustedShopsID apiToken:(NSString *)apiToken {
	
	// first get the image, we'll need that in any case:
	UIImage *sealImage = [UIImage imageWithContentsOfFile:
						  [TRSTrustbadgeBundle() pathForResource:@"iOS-SDK-Seal" ofType:@"png"]];
	_sealImageView = [[UIImageView alloc] initWithImage:sealImage];
	// prepare the contentView (needed for autolayout, see helper below)
	_contentView = [[UIView alloc] initWithFrame:self.frame];
	[self addSubview:_contentView];
	[_contentView addSubview:_sealImageView];
	
	// do the layout constraints
	[self doLayoutConstraints];

	// also, make our own background clear
	self.backgroundColor = [UIColor clearColor];
	_contentView.backgroundColor = [UIColor clearColor];
	
	// also set the offline marker label view, but then make it invisible
	_offlineMarker = [[UILabel alloc] init];
	_offlineMarker.text = @"OFFLINE";
	[_offlineMarker setFrame:_sealImageView.frame];
	[_offlineMarker setTextAlignment:NSTextAlignmentCenter];
	[_offlineMarker setAdjustsFontSizeToFitWidth:YES];
	[_offlineMarker setHidden:YES];
	[self addSubview:_offlineMarker];
	
	// set the default color:
	_customColor = [UIColor colorWithRed:(243.0 / 255.0) green:(112.0 / 255.0) blue:(0.0 / 255.0) alpha:1.0];
	
	// next save our id and token. this will also determine if we show an "offline" label or something over the seal
	_trustedShopsID = [trustedShopsID copy];
	_apiToken = [apiToken copy];
	
	// TODO: Check whether this really needs to be delayed (to avoid it flashing up even if the data is loaded immediately)
	[self displaySealAsOffline:YES afterDelay:1.0];
}

#pragma mark - Getting certificate & shop data from remote API

- (void)loadTrustbadgeWithSuccessBlock:(void (^)(void))success failureBlock:(void (^)(NSError *error))failure {
	void (^wins)(TRSTrustbadge *theTrustbadge) = ^(TRSTrustbadge *theTrustbadge) {
		[self displaySealAsOffline:NO afterDelay:0.0];
		
		self.trustbadge = theTrustbadge;
		self.trustbadge.debugMode = self.debugMode;
		self.trustbadge.customColor = _customColor;
		
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
				
//			case TRSErrorDomainUnknownError: // caught by default
			default:
				NSLog(@"[trustbadge] An unkown error occured.");
				break;
		}
		
		// we give back the error even if we could pre-handle it here
		if (failure) failure(error);
	};
	
	if (!self.apiToken || !self.trustedShopsID) {
		NSError *myError = [NSError errorWithDomain:TRSErrorDomain
											   code:TRSErrorDomainMissingTSIDOrAPIToken
										   userInfo:nil];
		NSLog(@"[trustbadge] There is no API token or TSID provided to contact the API.");
		if (failure) failure(myError);
	}
	
	// ensure the agent is in the correct debug mode:
	[TRSNetworkAgent sharedAgent].debugMode = self.debugMode;
	
	// the returned task is not important for now...
	[[TRSNetworkAgent sharedAgent] getTrustbadgeForTrustedShopsID:_trustedShopsID
														 apiToken:_apiToken
														  success:wins
														  failure:fails];

}

- (void)loadTrustbadgeWithFailureBlock:(void (^)(NSError *error))failure {
	[self loadTrustbadgeWithSuccessBlock:nil failureBlock:failure];
}

#pragma mark - Touch detection

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	if (![self.offlineMarker isHidden]) {
		[super touchesBegan:touches withEvent:event];
	}
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	if (![self.offlineMarker isHidden]) {
		[super touchesBegan:touches withEvent:event];
	}
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	if (![self.offlineMarker isHidden]) {
		[super touchesBegan:touches withEvent:event];
	} else {
		// Show the dialogue! But only if we touch inside the seal image!
		for (UITouch *touch in touches) {
			if ([_sealImageView pointInside:[touch locationInView:_sealImageView] withEvent:event]) {
				[self.trustbadge showTrustcardWithPresentingViewController:self.trustcardPresentingViewController];
				break;
			}
		}
		// relying on a proper action from the seal would be better, but this is easier to set up for now.
	}
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	if (![self.offlineMarker isHidden]) {
		[super touchesBegan:touches withEvent:event];
	}
}

#pragma mark - Special setter for the custom Color & debug mode

- (void)setCustomColor:(UIColor *)customColor {
	if (_customColor == customColor) { // save some nanoseconds...
		return;
	}
	_customColor = customColor;
	if (self.trustbadge) { // if the trustbadge is already loaded, set it's custom color to ours.
		self.trustbadge.customColor = _customColor;
	}
}

- (void)setDebugMode:(BOOL)debugMode {
	if (_debugMode != debugMode) {
		_debugMode = debugMode;
		[[TRSNetworkAgent sharedAgent] setDebugMode:_debugMode];
	}
}

#pragma mark - Helpers

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
		if (!(wasDelayed && !self.hasSealStateChangePending)) {
			if (off) { // the old idea was to fade it and display "OFFLINE", but we will completely hide it instead now
//				[self.sealImageView setAlpha:0.3];
//				[self.offlineMarker setHidden:NO];
				self.hidden = YES;
			} else {
//				[self.sealImageView setAlpha:1.0];
//				[self.offlineMarker setHidden:YES];
				self.hidden = NO;
			}
			[self setNeedsDisplay];
		}
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

// This looks more complicated than it is:
// It makes the seal image square (it's natural aspect ratio)
// It then ensures the image is centered in the content view and scaled with aspect-fit.
// Lastly it makes the contentView stretch over the entire trustbadge view.
// The reason we need the content view is that we don't know yet whether the trustbadge view will be using autolayout
// or not, but we want to use it for layout in our subview (i.e. the image). That way a programmatically
// instanciated trustbadge view (standard) keeps a translatesAutoresisingMaskIntoContraints property of YES (like it
// should) and can be used like any view (e.g. as a table header, which is not laid out with autolayout).
// This might not be the only way to achieve that, but it's the easiest to maintain I know and shouldn"t add too
// much overhead.
- (void)doLayoutConstraints {
	[_sealImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[_contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
	NSLayoutConstraint *aspectRatioForSeal = [NSLayoutConstraint constraintWithItem:_sealImageView
																		  attribute:NSLayoutAttributeWidth
																		  relatedBy:NSLayoutRelationEqual
																			 toItem:_sealImageView
																		  attribute:NSLayoutAttributeHeight
																		 multiplier:1.0
																		   constant:0.0];
	NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:_sealImageView
															   attribute:NSLayoutAttributeCenterX
															   relatedBy:NSLayoutRelationEqual
																  toItem:_contentView
															   attribute:NSLayoutAttributeCenterX
															  multiplier:1.0
																constant:0.0];
	NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:_sealImageView
															   attribute:NSLayoutAttributeCenterY
															   relatedBy:NSLayoutRelationEqual
																  toItem:_contentView
															   attribute:NSLayoutAttributeCenterY
															  multiplier:1.0
																constant:0.0];
	NSLayoutConstraint *lessOrEqualWidth = [NSLayoutConstraint constraintWithItem:_sealImageView
																		attribute:NSLayoutAttributeWidth
																		relatedBy:NSLayoutRelationLessThanOrEqual
																		   toItem:_contentView
																		attribute:NSLayoutAttributeWidth
																	   multiplier:1.0
																		 constant:0.0];
	NSLayoutConstraint *equalWidthHighP = [NSLayoutConstraint constraintWithItem:_sealImageView
																	   attribute:NSLayoutAttributeWidth
																	   relatedBy:NSLayoutRelationEqual
																		  toItem:_contentView
																	   attribute:NSLayoutAttributeWidth
																	  multiplier:1.0
																		constant:0.0];
	equalWidthHighP.priority = UILayoutPriorityDefaultHigh; // this is very important!
	NSLayoutConstraint *lessOrEqualHeight = [NSLayoutConstraint constraintWithItem:_sealImageView
																		 attribute:NSLayoutAttributeHeight
																		 relatedBy:NSLayoutRelationLessThanOrEqual
																			toItem:_contentView
																		 attribute:NSLayoutAttributeHeight
																		multiplier:1.0
																		  constant:0.0];
	NSLayoutConstraint *equalHeightHighP = [NSLayoutConstraint constraintWithItem:_sealImageView
																		attribute:NSLayoutAttributeHeight
																		relatedBy:NSLayoutRelationEqual
																		   toItem:_contentView
																		attribute:NSLayoutAttributeHeight
																	   multiplier:1.0
																		 constant:0.0];
	equalHeightHighP.priority = UILayoutPriorityDefaultHigh; // this is very important!
	
	[_sealImageView addConstraint:aspectRatioForSeal];
	[_contentView addConstraints:@[centerX, centerY, lessOrEqualWidth, lessOrEqualHeight, equalWidthHighP, equalHeightHighP]];
	
	[self addConstraints:[NSLayoutConstraint
						  constraintsWithVisualFormat:@"H:|-0-[_contentView]-0-|"
						  options:NSLayoutFormatDirectionLeadingToTrailing
						  metrics:nil
						  views:NSDictionaryOfVariableBindings(_contentView)]];
	[self addConstraints:[NSLayoutConstraint
						  constraintsWithVisualFormat:@"V:|-0-[_contentView]-0-|"
						  options:NSLayoutFormatDirectionLeadingToTrailing
						  metrics:nil
						  views:NSDictionaryOfVariableBindings(_contentView)]];
}

@end
