//
//  TRSPrivateBasicDataView.m
//  Pods
//
//  Created by Gero Herkenrath on 04/07/16.
//
//

#import "TRSPrivateBasicDataView.h"
#import "TRSPrivateBasicDataView+Private.h" // this header defines methods hidden from public views
#import "TRSNetworkAgent.h"
#import "TRSErrors.h"

NSString *const kTRSPrivateBasicDataViewTSIDKey = @"kTRSPrivateBasicDataViewTSIDKey";
NSString *const kTRSPrivateBasicDataViewApiTokenKey = @"kTRSPrivateBasicDataViewApiTokenKey";
NSString *const kTRSPrivateBasicDataViewDebugModeKey = @"kTRSPrivateBasicDataViewDebugModeKey";

// the class extension is defined in TRSPrivateBasicDataView+Private.h !

@implementation TRSPrivateBasicDataView

- (instancetype)initWithFrame:(CGRect)frame trustedShopsID:(NSString *)tsID apiToken:(NSString *)apiToken {
	self = [super initWithFrame:frame];
	if (self) {
		[self finishInit];
		_tsID = tsID;
		_apiToken = apiToken;
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	return [self initWithFrame:frame trustedShopsID:nil apiToken:nil];
}

// override this as needed, but be aware that super calls finishInit before the properties are decoded!
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self finishInit];
		_tsID = [aDecoder decodeObjectForKey:kTRSPrivateBasicDataViewTSIDKey];
		_apiToken = [aDecoder decodeObjectForKey:kTRSPrivateBasicDataViewApiTokenKey];
		_debugMode = [aDecoder decodeBoolForKey:kTRSPrivateBasicDataViewDebugModeKey];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:self.tsID forKey:kTRSPrivateBasicDataViewTSIDKey];
	[aCoder encodeObject:self.apiToken forKey:kTRSPrivateBasicDataViewApiTokenKey];
	[aCoder encodeBool:self.debugMode forKey:kTRSPrivateBasicDataViewDebugModeKey];
}

- (void)loadViewDataFromBackendWithSuccessBlock:(void (^)(void))success failureBlock:(void (^)(NSError *error))failure {
	
	// prepare the blocks for success and failure
	void (^successBlock)(id resultData) = ^(id resultData) {
		if (![self setupData:resultData] && failure) {
			// call failure with error
			NSError *invalidDataError = [NSError errorWithDomain:TRSErrorDomain
															code:TRSErrorDomainInvalidData
														userInfo:nil];
			failure(invalidDataError);
		} else {
			
			// note (dirty cheat): due to the rendering chain it's important to do this asynchronously, otherwise
			// we might get the wrong frame for this. Once it loads from the backend that's not too important,
			// but if the request is e.g. cached, it might screw us.
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[self finishLoading];
				if (success) {
					success();
				}
			});
		}
	};
	
	void (^failureBlock)(NSError *error) = ^(NSError *error) {
		
		NSString *logMessage = [self logStringForError:error];
		if (logMessage) {
			NSLog(@"%@", logMessage);
		} else if ([error.domain isEqualToString:TRSErrorDomain]) {
			NSLog(@"[trustbadge] An unkown error occured.");
		}
		// we give back the error in any case
		if (failure) failure(error);
	};
	// ensure the agent has the correct debugMode flag
	[TRSNetworkAgent sharedAgent].debugMode = self.debugMode;
	
	[self performNetworkRequestWithSuccessBlock:successBlock failureBlock:failureBlock];
}

#pragma mark - Methods supposed to be overridden in subclasses (TRSPrivateBasicDataViewLoading protocol)
- (void)finishInit {
	NSLog(@"TRSPrivateBasicDataView -finishInit: Nothing to finish, method should be overridden");
}

- (BOOL)setupData:(id)data {
	NSLog(@"TRSPrivateBasicDataView -setupData: Nothing to setup, method should be overridden");
	return YES;
}

- (void)finishLoading {
	NSLog(@"TRSPrivateBasicDataView -finishLoading: Nothing to finish, method should be overridden");
}

- (void)performNetworkRequestWithSuccessBlock:(void (^)(id result))successBlock failureBlock:(void(^)(NSError *error))failureBlock {
	// subclasses should override this!
	[NSException raise:@"TRSPrivateBasicDataViewSubclassingException"
				format:@"TRSPrivateBasicDataView was not subclassed correctly. A method that should have been overridden wasn't."];
}

- (NSString *)logStringForError:(NSError *)error {
	NSString *retVal = nil;
	if ([error.domain isEqualToString:TRSErrorDomain]) {
		switch (error.code) {
			case TRSErrorDomainInvalidAPIToken:
				retVal = @"[trustbadge] The provided API token is not correct";
				break;
			case TRSErrorDomainInvalidTSID:
				retVal = @"[trustbadge] The provided TSID is not correct.";
				break;
			case TRSErrorDomainTSIDNotFound:
				retVal = @"[trustbadge] The provided TSID could not be found.";
				break;
			case TRSErrorDomainInvalidData:
				retVal = @"[trustbadge] The received data is corrupt.";
				break;
			case TRSErrorDomainMissingTSIDOrAPIToken:
				retVal = @"[trustbadge] TSID or apiToken is missing.";
				break;
			default:
				break;
		}
	}
	return retVal;
}

@end
